require 'time'

module TicketSharing
  class Time

    attr_reader :value

    def initialize(value)
      case value
      when ::Time, nil
        @value = value
      when String
        @value = ::Time.parse(value.dup)
      else
        raise "Invalid value provided for requested_at"
      end
    end

    def as_json(_options = {})
      @value ? @value.strftime('%Y-%m-%d %H:%M:%S %z') : nil
    end

    def to_json(_options = {})
      JsonSupport.encode(as_json)
    end

    # Support method to play well with active record
    def to_time
      value
    end

  end
end
