module TicketSharing
  class Request

    attr_reader :raw_response

    MAX_REDIRECTS = 1

    def initialize(request_class, uri, body)
      @redirects = 0
      @uri = URI.parse(uri)
      @request_class = request_class
      @body = body
      @raw_request = new_raw_request
    end

    def set_header(key, value)
      @raw_request[key] = value
    end

    def send!
      @raw_request.body = @body

      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true if @uri.scheme == 'https'

      @raw_response = http.start do |http|
        http.request(@raw_request)
      end
    end

    def follow_redirect!
      if @redirects >= MAX_REDIRECTS
        raise TicketSharing::TooManyRedirects
      end

      @uri = URI.parse(@raw_response['Location'])
      @raw_request = new_raw_request

      self.send!

      @redirects += 1
    end

    def new_raw_request
      raw_request = @request_class.new(@uri.path)
      raw_request['Accept'] = 'application/json'

      raw_request
    end

  end
end
