require 'ticket_sharing/client'
require 'ticket_sharing/json_support'

module TicketSharing
  class Agreement

    attr_accessor :direction, :remote_url, :status

    def initialize(attrs = {})
      self.direction  = attrs['direction']  if attrs['direction']
      self.remote_url = attrs['remote_url'] if attrs['remote_url']
      self.status     = attrs['status'] if attrs['status']
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
      client = Client.new(remote_url)
      client.post('/agreements', self.to_json)
      client.success?
    end

  end
end
