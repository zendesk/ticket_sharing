require 'ticket_sharing/base'
require 'ticket_sharing/client'

module TicketSharing
  class Agreement < Base

    fields :receiver_url, :sender_url, :status, :uuid, :access_key

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      agreement = new(attributes)
    end

    def send_to(url)
      client = Client.new(url)
      client.post(relative_url, self.to_json)
      client.success?
    end

    def update_partner(url)
      client = Client.new(url, authentication_token)
      client.put(relative_url, self.to_json)
      client.success?
    end

    def relative_url
      '/agreements/' + uuid.to_s
    end

    def authentication_token
      "#{uuid}:#{access_key}"
    end

  end
end
