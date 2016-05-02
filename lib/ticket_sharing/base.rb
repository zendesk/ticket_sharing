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

    def self.first_ancestor
      ancestors.detect { |a| a != self }
    end

    def field_list
      if self.class.field_list.any?
        self.class.field_list
      else
        self.class.first_ancestor.field_list
      end
    end

    def initialize(attrs = {})
      field_list.each do |attribute|
        self.send("#{attribute}=", attrs[attribute.to_s]) if attrs.has_key?(attribute.to_s)
      end
    end

    def as_json(_options = {})
      field_list.inject({}) do |attrs, field|
        attrs[field.to_s] = send(field)
        attrs
      end
    end

    def to_json(_options = {})
      JsonSupport.encode(as_json)
    end

  end
end
