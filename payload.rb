require 'ticket_sharing/requester'

module TicketSharing
  class Payload

    attr_reader :errors, :requester

    def initialize(hash)
      @hash = hash
      @requester = Requester.new(hash[:requester])
      @actor = Actor.new(hash['actor'])

      @actor.uuid
    end

    def valid?
      validate
      @errors.empty?
    end

    def attributes
      { :uuid => @hash['uuid'] }
    end

    def ticket_attributes
      attributes = {}

      ['subject', 'description'].each do |key|
        attributes[key.to_sym] = @hash[key] if @hash[key]
      end

      attributes
    end

    def uuid
      @hash['uuid']
    end

    private

      def validate
        @errors = []

        if !@hash[:uuid]
          @errors << 'uuid must be present'
        end

        if !@hash[:requester]
          @errors << 'requester must be present'
        end

        if @hash[:requester] && !@hash[:requester][:uuid]
          @errors << 'requester uuid must be present'
        end
      end

  end
end