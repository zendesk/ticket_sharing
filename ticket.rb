require 'ticket_sharing/json_support'

module TicketSharing
  class Ticket

    FIELDS = [:subject, :description, :requested_at, :status]
    attr_accessor *FIELDS

    def initialize(attrs = {})
      FIELDS.each do |attribute|
        self.send("#{attribute}=", attrs[attribute.to_s])
      end
    end

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      ticket = new(attributes)
    end

    def to_json
    end

  end
end
