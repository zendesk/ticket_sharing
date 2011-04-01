require 'ticket_sharing/base'

module TicketSharing
  class Actor < Base
    fields :uuid, :name, :role
  end
end
