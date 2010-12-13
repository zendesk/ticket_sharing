require 'yajl'

module TicketSharing
  class Payload

    def self.parse_json(json)
      parser = Yajl::Parser.new
      result = parser.parse(json)
      new(result)
    end

    def initialize(hash)
      @hash = hash
    end

    def valid?
      @hash['uuid']
    end

    def ticket_attributes
      {
        'description' => @hash['description'],
        'priority'    => @hash['priority'],
        'status'      => @hash['status'],
        'subject'     => @hash['subject']
      }
    end

  end
end
