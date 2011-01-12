require 'ticket_sharing/client'
require 'ticket_sharing/json_support'

module TicketSharing
  class Agreement

    FIELDS = [:receiver_url, :sender_url, :status, :uuid]
    attr_accessor *FIELDS

    def initialize(attrs = {})
      FIELDS.each do |attribute|
        self.send("#{attribute}=", attrs[attribute.to_s])
      end
    end

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      agreement = new(attributes)
    end

    def to_json
      attributes = FIELDS.inject({}) do |attrs, field|
        attrs[field.to_s] = send(field)
        attrs
      end

      JsonSupport.encode(attributes)
    end

    # Maybe something like:
    #     client.send_agreement(self.to_json)
    def send_to(url)
      client = Client.new(url)
      client.post('/agreements', self.to_json)
      client.success?
    end

    def remote_url
      receiver_url + '/agreements'
    end

  end
end
