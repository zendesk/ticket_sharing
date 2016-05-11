require File.expand_path('../../test_helper', __FILE__)
require 'ticket_sharing/comment'

class TicketSharing::CommentTest < MiniTest::Unit::TestCase

  def test_should_initialize_from_a_hash
    hash = { 'uuid' => '63f127' }
    comment = TicketSharing::Comment.new(hash)
    assert_equal('63f127', comment.uuid)
  end

  def test_should_serialize_author
    comment = TicketSharing::Comment.new(valid_comment_attributes)
    comment.author = TicketSharing::Actor.new('uuid' => 'Actor123', 'name' => 'The Actor')

    json = comment.to_json
    hash = TicketSharing::JsonSupport.decode(json)

    assert_equal('The Actor', hash['author']['name'])
    assert_equal('Actor123', hash['author']['uuid'])
  end

  def test_should_serialize_attachments
    attachment = TicketSharing::Attachment.new('url' => 'http://example.com/')
    comment = TicketSharing::Comment.new(valid_comment_attributes)
    comment.attachments = [attachment]

    json = comment.to_json

    # Convert the json back to a hash just for easier assertions
    hash = TicketSharing::JsonSupport.decode(json)
    assert_equal('http://example.com/', hash['attachments'].first['url'])
  end

  def test_should_parse_from_json
    attributes = valid_comment_attributes
    json = TicketSharing::JsonSupport.encode(attributes)

    comment = TicketSharing::Comment.parse(json)
    assert_equal(attributes['uuid'], comment.uuid)
    assert_equal(attributes['body'], comment.body)
    assert_equal(attributes['html_body'], comment.html_body)
    assert_equal(attributes['authored_at'], comment.authored_at.to_time)
  end

  def test_should_parse_author_from_json
    attributes = valid_comment_attributes
    attributes['author'] = {
        'uuid' => 'Actor123',
        'name' => 'The Actor'
      }

    json = TicketSharing::JsonSupport.encode(attributes)
    comment = TicketSharing::Comment.parse(json)

    assert_equal('Actor123', comment.author.uuid)
    assert_equal('The Actor', comment.author.name)
  end

  def test_should_parse_attachments_from_json
    hash = { 'attachments' => [{ 'url' => 'http://example.com/foo.jpg' }] }
    json = TicketSharing::JsonSupport.encode(hash)

    parsed_comment = TicketSharing::Comment.parse(json)
    assert_equal('http://example.com/foo.jpg', parsed_comment.attachments.first.url)
  end

  def test_parse_should_not_blow_up_when_there_are_no_attachments
    json = TicketSharing::JsonSupport.encode({ 'attachments' => nil })
    assert parsed_comment = TicketSharing::Comment.parse(json)
  end

  def test_a_comment_that_does_not_specify_its_publicity_should_be_public
    comment = TicketSharing::Comment.new
    assert comment.public?
  end

  def test_a_comment_explicitly_set_to_private_should_not_be_public
    comment = TicketSharing::Comment.new({
      'public' => false
    })
    assert !comment.public?
  end

  def test_storing_authored_at
    now = Time.now
    comment = TicketSharing::Comment.new('authored_at' => now)
    assert_equal(now, comment.authored_at.to_time)
  end

  def test_should_serialize_custom_fields
    custom_fields = {
      'foo' => 'bar',
      'one' => 2,
      'three' => [4, 5, 6],
      'hash' => { 'key' => 'value' },
      'array' => [{'id' => 'abc', :url => "http://foo.bar/resources/1"},
                  {'id' => 'efg', :url => "http://foo.bar/resources/2"}]
    }

    comment = TicketSharing::Comment.new('custom_fields' => custom_fields)

    json = comment.to_json
    # Convert the json back to a hash just for easier assertions
    hash = TicketSharing::JsonSupport.decode(json)

    assert_equal('bar', hash['custom_fields']['foo'])
    assert_equal(2, hash['custom_fields']['one'])
    assert_equal([4, 5, 6], hash['custom_fields']['three'])
    assert_equal({'key' => 'value'}, hash['custom_fields']['hash'])
    assert_equal("http://foo.bar/resources/1", hash['custom_fields']['array'].first['url'])
    assert_equal("efg", hash['custom_fields']['array'].last['id'])
  end

  def test_should_parse_custom_fields_from_json
    hash = { 'custom_fields' =>
             { 'three' => [4, 5, 6],
               'array' => [{'id' => 'abc', :url => "http://foo.bar/resources/1"},
                           {'id' => 'efg', :url => "http://foo.bar/resources/2"}]
             }
           }
    json = TicketSharing::JsonSupport.encode(hash)

    parsed_comment = TicketSharing::Comment.parse(json)

    assert_equal("http://foo.bar/resources/1", parsed_comment.custom_fields['array'].first['url'])
    assert_equal([4, 5, 6], parsed_comment.custom_fields['three'])
  end

  def valid_comment_attributes
    {
      'uuid' => 'comment123',
      'body' => 'I need some help.  In fact, I need a lot of help.',
      'html_body' => 'I need some help.  In fact, I need a lot of help.',
      'authored_at' => Time.at(Time.now.to_i - 86400)
    }
  end

end
