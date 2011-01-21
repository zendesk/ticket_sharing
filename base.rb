require 'ticket_sharing/json_support'

module TicketSharing
  class Base

    def self.fields(*args)
      @fields = args
      attr_accessor *args
    end

    def self.field_list
      @fields || []
    end

    def field_list
      self.class.field_list
    end

    def initialize(attrs = {})
      field_list.each do |attribute|
        self.send("#{attribute}=", attrs[attribute.to_s])
      end
    end

    def to_json
      attributes = field_list.inject({}) do |attrs, field|
        attrs[field.to_s] = send(field)
        attrs
      end

      JsonSupport.encode(attributes)
    end

  end
end
