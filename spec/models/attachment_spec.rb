require 'spec_helper'
require 'ticket_sharing/attachment'

describe TicketSharing::Attachment do

  it 'initializes' do
    attributes = {
      'url'              => 'http://example.com/',
      'filename'         => 'foo.jpg',
      'display_filename' => 'foo.jpg',
      'content_type'     => 'text/jpeg'
    }

    attachment = described_class.new(attributes)

    expect(attachment.url).to eq('http://example.com/')
    expect(attachment.filename).to eq('foo.jpg')
    expect(attachment.display_filename).to eq('foo.jpg')
    expect(attachment.content_type).to eq('text/jpeg')
  end

end
