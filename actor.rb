module TicketSharing
  class Actor

    attr_accessor :uuid

    def initialize(hash = {})
      @uuid = hash['uuid']
    end

    def valid?
      uuid
    end

  end
end
