module TicketSharing
  class Payload

    def initialize(hash)
      @hash = hash
    end

    def valid?
      @hash[:uuid]
    end

    def ticket_attributes
      {
        :description => @hash['description'],
        :priority    => @hash['priority'],
        :status      => @hash['status'],
        :subject     => @hash['subject']
      }
    end

  end
end
