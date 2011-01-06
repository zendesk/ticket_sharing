require 'ticket_sharing/client'
require 'ticket_sharing/json_support'

module TicketSharing
  class Agreement

    attr_accessor :direction

    def initialize(attrs = {})
      self.direction = attrs['direction'] if attrs['direction']
    end

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      agreement = new(attributes)
    end

    def to_json
      attributes = { :direction => direction }
      JsonSupport.encode(attributes)
    end

    def send_to_partner
      client = Client.new
    end

  end
end
