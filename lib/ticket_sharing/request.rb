require 'ticket_sharing'
require 'ticket_sharing/error'

module TicketSharing
  class Request
    MAX_REDIRECTS = 2

    CA_PATH = "/etc/ssl/certs"

    def initialize(connection = TicketSharing.connection)
      @connection = connection
    end

    def request(method, url, options = {})
      raise ArgumentError, "Unsupported method: #{method.inspect}" unless %i(get post put delete).include?(method)

      response = send_request(method, url, options)
      follow_redirects!(method, response, options)
    end

    private

    def send_request(method, url, options)
      response = nil

      with_ssl_connection(options) do
        response = @connection.send(method) do |request|
          configure_request(request, url, options)
        end
      end

      response
    end

    def with_ssl_connection(options)
      ssl_config = {}
      ssl_config[:ca_path] = CA_PATH if File.exist?(CA_PATH)
      ssl_config[:verify]  = false   if options[:ssl] && options[:ssl][:verify] == false

      old_configuration = @connection.instance_variable_get(:@ssl)
      @connection.instance_variable_set(:@ssl, ssl_config) unless ssl_config.empty?
      yield
    ensure
      @connection.instance_variable_set(:@ssl, old_configuration)
    end

    def configure_request(request, url, options)
      _uri = URI.parse(url)

      request.url url
      {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json'
      }.merge(options[:headers] || {}).each do |h, v|
        request.headers[h] = v
      end

      request.body = options[:body]
    end

    def follow_redirects!(method, response, options)
      redirects = 0
      while (300..399).include?(response.status)
        if redirects >= MAX_REDIRECTS
          raise TicketSharing::TooManyRedirects
        else
          redirects += 1
        end
        response = send_request(method, response['Location'], options)
      end
      response
    end
  end
end
