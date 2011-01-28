module TicketSharing
  class Client

    attr_reader :response

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

    def success?
      raise "No call made to determine success" unless response
      Net::HTTPSuccess === response
    end

    def code
      response.code.to_i
    end

    private
      def send_request(request_class, path, body)
        uri = URI.parse(@base_url + path)
        request = request_class.new(uri.path)
        request['X-Ticket-Sharing-Token'] = @credentials if @credentials
        request.body = body

        @response = Net::HTTP.new(uri.host, uri.port).start do |http|
          http.request(request)
        end
      end

  end
end
