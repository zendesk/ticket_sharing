require 'test_helper'
require 'ticket_sharing/comment'

describe TicketSharing::Comment do
  let(:described_class) { TicketSharing::Comment }

  let(:valid_comment_attributes) do
    {
      'uuid' => 'comment123',
      'body' => 'I need some help.  In fact, I need a lot of help.',
      'html_body' => '<strong>I need some help</strong>.  In fact, I need a lot of help.',
      'authored_at' => Time.at(Time.now.to_i - 86400)
    }
  end

  it 'initializes from a hash' do
    hash = { 'uuid' => '63f127' }
    comment = described_class.new(hash)
    expect(comment.uuid).must_equal('63f127')
  end

  it 'serializes author' do
    comment = described_class.new(valid_comment_attributes)
    comment.author = TicketSharing::Actor.new('uuid' => 'Actor123', 'name' => 'The Actor')

    json = comment.to_json
    hash = TicketSharing::JsonSupport.decode(json)

    expect(hash['author']['name']).must_equal('The Actor')
    expect(hash['author']['uuid']).must_equal('Actor123')
  end

  it 'serializes attachments' do
    attachment = TicketSharing::Attachment.new('url' => 'http://example.com/')
    comment = described_class.new(valid_comment_attributes)
    comment.attachments = [attachment]

    json = comment.to_json

    # Convert the json back to a hash just for easier assertions
    hash = TicketSharing::JsonSupport.decode(json)
    expect(hash['attachments'].first['url']).must_equal('http://example.com/')
  end

  it 'parses from_json' do
    attributes = valid_comment_attributes
    json = TicketSharing::JsonSupport.encode(attributes)

    comment = described_class.parse(json)
    expect(comment.uuid).must_equal(attributes['uuid'])
    expect(comment.body).must_equal(attributes['body'])
    expect(comment.html_body).must_equal(attributes['html_body'])
    expect(comment.authored_at.to_time).must_equal(attributes['authored_at'])
  end

  it 'parses author_from_json' do
    attributes = valid_comment_attributes
    attributes['author'] = {
      'uuid' => 'Actor123',
      'name' => 'The Actor'
    }

    json = TicketSharing::JsonSupport.encode(attributes)
    comment = described_class.parse(json)

    expect(comment.author.uuid).must_equal('Actor123')
    expect(comment.author.name).must_equal('The Actor')
  end

  it 'parses attachments_from_json' do
    hash = { 'attachments' => [{ 'url' => 'http://example.com/foo.jpg' }] }
    json = TicketSharing::JsonSupport.encode(hash)

    parsed_comment = described_class.parse(json)
    expect(parsed_comment.attachments.first.url).must_equal('http://example.com/foo.jpg')
  end

  it 'parses should not blow up when there are no attachments' do
    json = TicketSharing::JsonSupport.encode('attachments' => nil)
    expect(described_class.parse(json)).wont_be_nil
  end

  it 'creates a comment that does not specify its publicity should be public' do
    comment = described_class.new
    expect(comment).must_be :public?
  end

  it 'creates a comment explicitly set to private should not be public' do
    comment = described_class.new(
      'public' => false
    )
    expect(comment).wont_be :public?
  end

  it 'stores authored at' do
    now = Time.now
    comment = described_class.new('authored_at' => now)
    expect(comment.authored_at.to_time).must_equal(now)
  end

  it 'serializes custom_fields' do
    custom_fields = {
      'foo'   => 'bar',
      'one'   => 2,
      'three' => [4, 5, 6],
      'hash'  => { 'key' => 'value' },
      'array' => [
        {'id' => 'abc', url: "http://foo.bar/resources/1"},
        {'id' => 'efg', url: "http://foo.bar/resources/2"}
      ]
    }

    comment = described_class.new('custom_fields' => custom_fields)

    json = comment.to_json
    # Convert the json back to a hash just for easier assertions
    hash = TicketSharing::JsonSupport.decode(json)

    expect(hash['custom_fields']['foo'])  .must_equal('bar')
    expect(hash['custom_fields']['one'])  .must_equal(2)
    expect(hash['custom_fields']['three']).must_equal([4, 5, 6])
    expect(hash['custom_fields']['hash']) .must_equal('key' => 'value')

    expect(hash['custom_fields']['array'].first['url']).must_equal("http://foo.bar/resources/1")
    expect(hash['custom_fields']['array'].last['id'])  .must_equal("efg")
  end

  it 'parses custom_fields_from_json' do
    hash = { 'custom_fields' =>
             { 'three' => [4, 5, 6],
               'array' => [
                 {'id' => 'abc', url: "http://foo.bar/resources/1"},
                 {'id' => 'efg', url: "http://foo.bar/resources/2"}
               ]
             }
           }
    json = TicketSharing::JsonSupport.encode(hash)

    parsed_comment = described_class.parse(json)

    expect(parsed_comment.custom_fields['array'].first['url']).must_equal("http://foo.bar/resources/1")
    expect(parsed_comment.custom_fields['three']).must_equal([4, 5, 6])
  end
end
