module TicketSharing
  class Payload

    def initialize(hash)
      @hash = hash
    end

    def valid?
      @hash[:uuid]
    end

    def attributes
      {
        :uuid => @hash[:uuid]
      }
    end

    def ticket_attributes
      {
        :description => @hash['description'],
        :subject     => @hash['subject']
      }
    end

  end
end
