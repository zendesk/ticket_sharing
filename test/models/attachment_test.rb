require 'test_helper'
require 'ticket_sharing/attachment'

describe TicketSharing::Attachment do

  it 'initializes' do
    attributes = {
      'url'              => 'http://example.com/',
      'filename'         => 'foo.jpg',
      'display_filename' => 'foo.jpg',
      'content_type'     => 'text/jpeg'
    }

    attachment = TicketSharing::Attachment.new(attributes)

    expect(attachment.url).must_equal('http://example.com/')
    expect(attachment.filename).must_equal('foo.jpg')
    expect(attachment.display_filename).must_equal('foo.jpg')
    expect(attachment.content_type).must_equal('text/jpeg')
  end

end
