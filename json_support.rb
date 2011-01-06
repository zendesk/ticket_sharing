require 'yajl'

module TicketSharing
  class JsonSupport

    def self.encode(attributes)
      Yajl::Encoder.encode(attributes)
    end

    def self.decode(json)
      Yajl::Parser.new.parse(json)
    end

  end
end
