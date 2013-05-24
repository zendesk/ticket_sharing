require 'ticket_sharing/error'

module TicketSharing
  class Request
    MAX_REDIRECTS = 2

    CA_PATH = "/etc/ssl/certs"

    def request(method, url, options = {})
      request_class = case method
      when :get    then Net::HTTP::Get
      when :post   then Net::HTTP::Post
      when :put    then Net::HTTP::Put
      when :delete then Net::HTTP::Delete
      else
        raise ArgumentError, "Unsupported method: #{method.inspect}"
      end

      response = send_request(request_class, url, options)

      follow_redirects!(request_class, response, options)
    end

    private

    def send_request(request_class, url, options)
      uri = URI.parse(url)
      request = build_request(request_class, uri, options)
      send!(request, uri, options)
    end

    def build_request(request_class, uri, options)
      request = request_class.new(uri.path)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'

      (options[:headers] || {}).each do |k, v|
        request[k] = v
      end

      request.body = options[:body]

      request
    end

    def send!(request, uri, options)
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.ca_path = CA_PATH if File.exist?(CA_PATH)

        if options[:ssl] && options[:ssl][:verify] == false
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end

      http.start { |http| http.request(request) }
    end

    def follow_redirects!(request_class, response, options)
      redirects = 0
      while (300..399).include?(response.code.to_i)
        if redirects >= MAX_REDIRECTS
          raise TicketSharing::TooManyRedirects
        else
          redirects += 1
        end
        response = send_request(request_class, response['Location'], options)
      end
      response
    end
  end
end
