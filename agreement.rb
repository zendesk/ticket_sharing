require 'ticket_sharing/base'
require 'ticket_sharing/client'
require 'ticket_sharing/actor'

module TicketSharing
  class Agreement < Base

    fields :receiver_url, :sender_url, :status, :uuid, :access_key, :name,
      :current_actor

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      agreement = new(attributes)
      if agreement.current_actor
        agreement.current_actor = TicketSharing::Actor.new(agreement.current_actor)
      end
      agreement
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
