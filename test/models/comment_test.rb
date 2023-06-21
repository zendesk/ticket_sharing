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
    assert_equal '63f127', comment.uuid
  end

  it 'serializes author' do
    comment = described_class.new(valid_comment_attributes)
    comment.author = TicketSharing::Actor.new('uuid' => 'Actor123', 'name' => 'The Actor')

    json = comment.to_json
    hash = TicketSharing::JsonSupport.decode(json)

    assert_equal 'The Actor', hash['author']['name']
    assert_equal 'Actor123', hash['author']['uuid']
  end

  it 'serializes attachments' do
    attachment = TicketSharing::Attachment.new('url' => 'http://example.com/')
    comment = described_class.new(valid_comment_attributes)
    comment.attachments = [attachment]

    json = comment.to_json

    # Convert the json back to a hash just for easier assertions
    hash = TicketSharing::JsonSupport.decode(json)
    assert_equal 'http://example.com/', hash['attachments'].first['url']
  end

  it 'parses from_json' do
    attributes = valid_comment_attributes
    json = TicketSharing::JsonSupport.encode(attributes)

    comment = described_class.parse(json)
    assert_equal attributes['uuid'], comment.uuid
    assert_equal attributes['body'], comment.body
    assert_equal attributes['html_body'], comment.html_body
    assert_equal attributes['authored_at'], comment.authored_at.to_time
  end

  it 'parses author_from_json' do
    attributes = valid_comment_attributes
    attributes['author'] = {
      'uuid' => 'Actor123',
      'name' => 'The Actor'
    }

    json = TicketSharing::JsonSupport.encode(attributes)
    comment = described_class.parse(json)

    assert_equal 'Actor123', comment.author.uuid
    assert_equal 'The Actor', comment.author.name
  end

  it 'parses attachments_from_json' do
    hash = { 'attachments' => [{ 'url' => 'http://example.com/foo.jpg' }] }
    json = TicketSharing::JsonSupport.encode(hash)

    parsed_comment = described_class.parse(json)
    assert_equal 'http://example.com/foo.jpg', parsed_comment.attachments.first.url
  end

  it 'parses should not blow up when there are no attachments' do
    json = TicketSharing::JsonSupport.encode('attachments' => nil)
    refute_nil described_class.parse(json)
  end

  it 'creates a comment that does not specify its publicity should be public' do
    comment = described_class.new
    assert_predicate comment, :public?
  end

  it 'creates a comment explicitly set to private should not be public' do
    comment = described_class.new(
      'public' => false
    )
    refute_predicate comment, :public?
  end

  it 'stores authored at' do
    now = Time.now
    comment = described_class.new('authored_at' => now)
    assert_equal now, comment.authored_at.to_time
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

    assert_equal 'bar', hash['custom_fields']['foo']
    assert_equal 2, hash['custom_fields']['one']
    assert_equal [4, 5, 6], hash['custom_fields']['three']
    assert_equal({ 'key' => 'value' }, hash['custom_fields']['hash'])

    assert_equal "http://foo.bar/resources/1", hash['custom_fields']['array'].first['url']
    assert_equal "efg", hash['custom_fields']['array'].last['id']
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

    assert_equal "http://foo.bar/resources/1", parsed_comment.custom_fields['array'].first['url']
    assert_equal [4, 5, 6], parsed_comment.custom_fields['three']
  end
end
