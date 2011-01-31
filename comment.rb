require 'ticket_sharing/base'
require 'ticket_sharing/actor'

module TicketSharing
  class Comment < Base

    fields :uuid, :author, :body, :created_at

    def self.parse(json)
      attributes = JsonSupport.decode(json)
      comment = new(attributes)
      if comment.author
        comment.author = Actor.new(comment.author)
      end
      comment
    end

  end
end
