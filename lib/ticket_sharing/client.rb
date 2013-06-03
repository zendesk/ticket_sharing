require 'ticket_sharing/error'
require 'ticket_sharing/request'

module TicketSharing
  class Client
    def initialize(base_url, credentials=nil)
      @base_url    = base_url
      @credentials = credentials
    end

    def post(path, body, options={})
      send_request(:post, path, body, options)
    end

    def put(path, body, options={})
      send_request(:put, path, body, options)
    end

    def delete(path, options={})
      send_request(:delete, path, '', options)
    end

    def success?
      @success
    end

    private

    def send_request(method, path, body, options)
      headers = {'X-Ticket-Sharing-Token' => @credentials} if @credentials
      options = options.merge(:body => body, :headers => headers)
      response = TicketSharing::Request.new.request(method, @base_url + path, options)

      handle_response(response)
    end

    def handle_response(response)
      @success = case response.code.to_i
      when (200..299)
        true
      when 401, 403, 404, 405, 408, 410, 422, 500..599
         false
      else
        raise TicketSharing::Error.new(%Q{#{response.code} "#{response.message}"\n\n#{response.body}})
      end
      response
    end
  end
end
