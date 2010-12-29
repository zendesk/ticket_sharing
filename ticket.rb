require 'date'

require 'ticket_sharing/actor'

module TicketSharing
  class Ticket

    FIELDS = [:subject, :description, :requested_at]
    REQUIRED_FIELDS = [:description, :requested_at]

    attr_accessor *FIELDS

    def requested_at_valid?
      begin

        case requested_at
        when nil then false
        when Time, DateTime then true
        else DateTime.parse(requested_at.to_s)
        end

      rescue ArgumentError
      end
    end

    def subject_valid?
      !subject.nil?
    end

    def description_valid?
      !description.nil?
    end

    def create
      return unless valid_for_create?
    end

    def valid_for_create?
      required_fields_are_given? &&
      given_fields_are_valid?
    end

    def required_fields_are_given?
      REQUIRED_FIELDS.all? { |field| !send(field).nil? }
    end

    def update
      return unless valid_for_update?
    end

    def valid_for_update?
      given_fields_are_valid?
    end

    def given_fields_are_valid?
      given_fields.all? { |field| send("#{field}_valid?") }
    end

    def given_fields
      FIELDS.select { |field| !send(field).nil? }
    end

  end
end
