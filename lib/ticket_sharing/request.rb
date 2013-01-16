module TicketSharing
  class Request

    attr_reader :raw_response

    # this should very rarely have to go above 2, and definitely never any higher than 5
    MAX_REDIRECTS = 2

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

      if @uri.scheme == 'https'
        http.use_ssl = true
        http.ca_path = "/etc/ssl/certs" if File.exist?("/etc/ssl/certs")
      end

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
      raw_request['Content-Type'] = 'application/json'

      if @raw_request && token = @raw_request['X-Ticket-Sharing-Token']
        raw_request['X-Ticket-Sharing-Token'] = token
      end

      raw_request
    end

  end
end
