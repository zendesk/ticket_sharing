require 'ticket_sharing/base'
require 'ticket_sharing/actor'

module TicketSharing
  class Comment < Base

    fields :uuid, :author, :body, :created_at

    def initialize(params={})
      super(params)
      if Hash === author
        self.author = Actor.new(author)
      end
    end

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      new(attributes)
    end

  end
end
