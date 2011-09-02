require 'ticket_sharing/error'
require 'ticket_sharing/request'

module TicketSharing
  class Client

    attr_reader :response, :code

    def initialize(base_url, credentials=nil)
      @base_url    = base_url
      @credentials = credentials
    end

    def post(path, body)
      send_request(Net::HTTP::Post, path, body)
    end

    def put(path, body)
      send_request(Net::HTTP::Put, path, body)
    end

    def delete(path)
      send_request(Net::HTTP::Delete, path, '')
    end

    def success?
      @success
    end

    private

      def send_request(request_class, path, body)
        request = TicketSharing::Request.new(request_class, @base_url + path, body)

        if @credentials
          request.set_header('X-Ticket-Sharing-Token', @credentials)
        end

        request.send!

        handle_response(request)
      end

      def handle_response(request)
        @response = request.raw_response
        @code = response.code.to_i

        case response
        when Net::HTTPSuccess
          @success = true
          response
        when Net::HTTPMovedPermanently, Net::HTTPFound
          request.follow_redirect!
          handle_response(request)
        else
          raise TicketSharing::Error.new(%Q{#{response.code} "#{response.message}"\n\n#{response.body}})
        end
      end

  end
end
