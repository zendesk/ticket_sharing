module TicketSharing
  class Client

    attr_reader :response

    def initialize(base_url)
      @base_url = base_url
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

    private
      def send_request(request_class, path, body)
        uri = URI.parse(@base_url + path)
        request = request_class.new(uri.path)
        request.body = body

        @response = Net::HTTP.new(uri.host, uri.port).start do |http|
          http.request(request)
        end
      end

  end
end
