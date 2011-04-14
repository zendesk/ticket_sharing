require 'ticket_sharing/base'

module TicketSharing
  class Actor < Base

    fields :uuid, :name, :role

    def agent?
      role == 'agent'
    end

  end
end
