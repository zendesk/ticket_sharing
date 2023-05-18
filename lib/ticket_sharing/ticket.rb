require 'ticket_sharing/base'
require 'ticket_sharing/client'
require 'ticket_sharing/actor'
require 'ticket_sharing/comment'
require 'ticket_sharing/agreement'
require 'ticket_sharing/time'

module TicketSharing
  class Ticket < Base

    fields :uuid, :subject, :requested_at, :status, :requester, :comments,
      :current_actor, :tags, :original_id, :custom_fields, :custom_status

    attr_accessor :agreement
    attr_reader :response

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      ticket = new(attributes)

      if ticket.requester
        ticket.requester = Actor.new(ticket.requester)
      end

      if ticket.current_actor
        ticket.current_actor = Actor.new(ticket.current_actor)
      end

      if ticket.comments
        ticket.comments = ticket.comments.map { |comment| Comment.new(comment) }
      end

      ticket
    end

    # TSTODO make all of these setters behave this way, not like they do in parse
    def requested_at=(val)
      @requested_at = TicketSharing::Time.new(val)
    end

    def comments
      @comments ||= []
    end

    def send_to(url)
      raise "Agreement not present" unless agreement

      client = Client.new(url, agreement.authentication_token)
      @response = client.post(relative_url, self.to_json)

      @response.status
    end

    def update_partner(url)
      client = Client.new(url, agreement.authentication_token)
      @response = client.put(relative_url, self.to_json)

      @response.status
    end

    def unshare(base_url)
      client = Client.new(base_url, agreement.authentication_token)
      @response = client.delete(relative_url)

      @response.status
    end

    def relative_url
      "/tickets/#{uuid}"
    end

  end
end
