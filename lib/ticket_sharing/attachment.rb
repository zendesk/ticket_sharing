require 'ticket_sharing/base'

module TicketSharing
  class Attachment < Base

    fields :url, :filename, :content_type, :display_filename

  end
end
