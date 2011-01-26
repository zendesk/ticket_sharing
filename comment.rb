require 'ticket_sharing/base'

module TicketSharing
  class Comment < Base

    fields :uuid, :author, :body, :created_at

  end
end
