require 'ticket_sharing/client'
require 'ticket_sharing/json_support'

module TicketSharing
  class Agreement

    attr_accessor :direction, :remote_url

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
      # Client API subject to change.
      client = Client.new(remote_url)
      client.post('/agreements', self.to_json)
    end

  end
end
