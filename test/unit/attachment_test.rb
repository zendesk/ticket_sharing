require 'test_helper'
require 'ticket_sharing/attachment'

class TicketSharing::AttachmentTest < MiniTest::Unit::TestCase

  def test_should_initialize
    attributes = {
      'url' => 'http://example.com/',
      'filename' => 'foo.jpg',
      'content_type' => 'text/jpeg'
    }
    attachment = TicketSharing::Attachment.new(attributes)

    assert_equal('http://example.com/', attachment.url)
    assert_equal('foo.jpg', attachment.filename)
    assert_equal('text/jpeg', attachment.content_type)
  end

end
