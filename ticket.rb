require 'ticket_sharing/client'
require 'ticket_sharing/json_support'

module TicketSharing
  class Ticket

    FIELDS = [:uuid, :subject, :description, :requested_at, :status]
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
      attributes = FIELDS.inject({}) do |attrs, field|
        attrs[field.to_s] = send(field)
        attrs
      end

      JsonSupport.encode(attributes)
    end

    def send_to(url)
      client = Client.new(url)
      client.post(relative_url, self.to_json)
      client.success?
    end

    def relative_url
      "/tickets/#{uuid}"
    end

  end
end
