require 'test_helper'
require 'ticket_sharing/client'

class TicketSharing::ClientTest < MiniTest::Unit::TestCase

  def setup
    @base_url = 'http://example.com/sharing'
    @path     = '/'

    FakeWeb.clean_registry
    FakeWeb.last_request = nil
  end

  def do_request(method, options={})
    client = TicketSharing::Client.new(@base_url, options[:token])
    client.send(method, @path, "{}")
    client
  end

  def test_a_successful_post_with_200_response
    FakeWeb.register_uri(:post, @base_url + @path, :body => '')
    client = do_request(:post)
    assert client.success?
    assert_equal(200, client.code)
    assert !client.response.nil?
    assert_equal('POST', FakeWeb.last_request.method)
  end

  def test_a_successful_post_with_ssl
    @base_url = 'https://example.com/sharing'

    FakeWeb.register_uri(:post, @base_url + @path, :body => '',
      :status => [200, 'OK'])

    client = do_request(:post)
  end

  def test_a_successful_post_with_201_response
    FakeWeb.register_uri(:post, @base_url + @path, :body => '', :status => '201')
    client = do_request(:post)
    assert client.success?
    assert_equal(201, client.code)
    assert_equal('POST', FakeWeb.last_request.method)
  end

  def test_should_follow_redirects
    client = TicketSharing::Client.new('http://example.com/sharing')

    FakeWeb.register_uri(:post, 'http://example.com/sharing/', :body => '',
      :status => '302', :location => 'https://example.com/sharing/')
    FakeWeb.register_uri(:post, 'https://example.com/sharing/',
      :body => 'the final url', :status => '201')

    response = client.post('/', '')
    assert_equal('201', response.code)
    assert_equal('the final url', response.body)

    assert client.success?
  end

  def test_should_not_follow_more_than_x_redirects
    client = TicketSharing::Client.new('http://example.com/sharing')

    FakeWeb.register_uri(:post, 'http://example.com/sharing/', :body => '',
      :status => '302', :location => 'http://example.com/sharing/')

    assert_raises(TicketSharing::TooManyRedirects) do
      response = client.post('/', '')
    end
  end

  def test_a_failing_post_with_400_response
    the_body = "{'error': 'the error'}"
    FakeWeb.register_uri(:post, @base_url + @path,
      :body => the_body, :status => [400, 'Bad Request'])

    begin
      client = do_request(:post)
      flunk 'should raise an exception'
    rescue TicketSharing::Error => e
      assert_equal(%Q{400 "Bad Request"\n\n} + the_body, e.message)
    end
  end

  def test_a_failing_post_with_404_response
    the_body = "{'error': 'the error'}"
    FakeWeb.register_uri(:post, @base_url + @path,
      :body => the_body, :status => [404, 'Not Found'])

    client = do_request(:post)
    assert !client.success?
  end

  def test_a_failing_post_with_410_response
    the_body = "{'error': 'the error'}"
    FakeWeb.register_uri(:post, @base_url + @path,
      :body => the_body, :status => [410, 'Gone'])

    client = do_request(:post)
    assert !client.success?
    assert_equal("410", client.response.code)
  end

  def test_a_failing_post_with_a_5xx_response
    the_body = "{'error': 'the error'}"
    FakeWeb.register_uri(:post, @base_url + @path,
      :body => the_body, :status => [500, 'Internal Server Error'])

    client = do_request(:post)
    assert !client.success?
  end

  def test_a_successful_post_without_a_token
    FakeWeb.register_uri(:post, @base_url + @path, :body => '')
    client = do_request(:post)
    assert client.success?
    assert_nil FakeWeb.last_request['X-Ticket-Sharing-Token']
  end

  def test_a_successful_post_with_auth_token
    FakeWeb.register_uri(:post, @base_url + @path, :body => '')
    client = do_request(:post, :token => 'the_token')
    assert client.success?
    assert_equal('the_token', FakeWeb.last_request['X-Ticket-Sharing-Token'])
  end

  def test_a_successful_put
    FakeWeb.register_uri(:put, 'http://example.com/sharing/', :body => '')
    client = do_request(:put)
    assert client.success?
    assert_equal('PUT', FakeWeb.last_request.method)
  end

  def test_a_successful_put_with_auth_token
    FakeWeb.register_uri(:post, 'http://example.com/sharing/', :body => '')
    client = do_request(:post, :token => 'the_token')
    assert client.success?
    assert_equal('the_token', FakeWeb.last_request['X-Ticket-Sharing-Token'])
  end

  def test_a_successful_delete
    FakeWeb.last_request = nil
    FakeWeb.register_uri(:delete, 'http://example.com/sharing/tickets/t1',
      :body => '')

    client = TicketSharing::Client.new('http://example.com/sharing/')
    client.delete('tickets/t1')

    assert response = FakeWeb.last_request
    assert_equal('/sharing/tickets/t1', response.path)
    assert_equal('DELETE', response.method)
  end

end
