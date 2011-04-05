require 'ticket_sharing/base'
require 'ticket_sharing/actor'
require 'ticket_sharing/time'
require 'ticket_sharing/attachment'

module TicketSharing
  class Comment < Base

    fields :uuid, :author, :body, :authored_at, :public, :attachments

    def initialize(params={})
      self.public = true

      super(params)

      if Hash === author
        self.author = Actor.new(author)
      end
    end

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      new(attributes)
    end

    def authored_at=(value)
      @authored_at = TicketSharing::Time.new(value)
    end

    def public?
      public
    end

  end
end
