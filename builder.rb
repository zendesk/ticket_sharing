module TicketSharing
  class Builder

    attr_reader :ticket

    def initialize(payload, account, partner)
      @payload = payload
      @account = account
      @partner = partner
    end

    def build_objects
      @requester = find_or_build_requester
      @ticket    = @account.tickets.build(@payload.ticket_attributes)

      @shared_ticket = @account.shared_tickets.build(@payload.attributes)
      @shared_ticket.partner = @partner
      @shared_ticket.ticket  = @ticket
    end

    def find_or_build_requester
      identity = UserForeignIdentity.find_by_account_id_and_value(@account.id,
        @payload.requester.uuid)

      if !identity
        user = User.new({
          :account => @account,
          :name => @payload.requester.name,
          :email => @payload.requester.email
        })

        identity = UserForeignIdentity.create({
          :account => @account,
          :user => user,
          :value => @payload.requester.uuid
        })
      end

      identity.user
    end

    def create
      ActiveRecord::Base.connection.transaction do
        build_objects
        @ticket.save(@requester) && @shared_ticket.save
      end
    end

  end
end
