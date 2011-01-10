module TicketSharing
  class Client

    attr_reader :response

    def initialize(base_url)
      @base_url = base_url
    end

    def post(path, body)
      uri = URI.parse(@base_url + path)
      request = Net::HTTP::Post.new(uri.path)
      request.body = body

      @response = Net::HTTP.new(uri.host, uri.port).start do |http|
        http.request(request)
      end
    end

    def success?
      raise "No call made to determine success" unless response
      Net::HTTPSuccess === response
    end

  end
end
