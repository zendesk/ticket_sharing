module TicketSharing
  JSON_PARSER = begin
    require 'multi_json'
    MultiJson
  rescue LoadError
    require 'json'
    JSON
  end

  class JsonSupport

    def self.encode(attributes)
      JSON_PARSER.dump(attributes)
    end

    def self.decode(json)
      JSON_PARSER.load(json)
    end

  end
end
