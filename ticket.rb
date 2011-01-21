require 'ticket_sharing/base'
require 'ticket_sharing/client'
require 'ticket_sharing/agreement'

module TicketSharing
  class Ticket < Base

    fields :uuid, :subject, :description, :requested_at, :status

    attr_accessor :agreement

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      ticket = new(attributes)
    end

    def send_to(url)
      raise "Agreement not present" unless agreement

      client = Client.new(url, agreement.authentication_token)
      client.post(relative_url, self.to_json)
      client.success?
    end

    def relative_url
      "/tickets/#{uuid}"
    end

  end
end
