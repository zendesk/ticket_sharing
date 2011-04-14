require 'test_helper'
require 'ticket_sharing/attachment'

class TicketSharing::AttachmentTest < Test::Unit::TestCase

  def test_should_initialize
    attributes = {
      'url' => 'http://example.com/',
      'filename' => 'foo.jpg'
    }
    attachment = TicketSharing::Attachment.new(attributes)

    assert_equal('http://example.com/', attachment.url)
    assert_equal('foo.jpg', attachment.filename)
  end

end
