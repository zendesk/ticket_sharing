module TicketSharing
  class Builder

    attr_reader :ticket

    def initialize(payload, account, partner)
      @payload = payload
      @account = account

      @requester = find_or_create_requester
      @ticket    = account.tickets.build(payload.ticket_attributes)

      @shared_ticket = account.shared_tickets.build(payload.attributes)
      @shared_ticket.partner = partner
      @shared_ticket.ticket = @ticket
    end

    def find_or_create_requester
      identity = UserForeignIdentity.find_by_account_id_and_value(@account.id,
        @payload.requester.uuid)

      if !identity
        user = User.create!({
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

    def save
      @ticket.save(@requester) && @shared_ticket.save
    end

  end
end
