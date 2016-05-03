require File.expand_path('../../test_helper', __FILE__)
require 'ticket_sharing/client'

class TicketSharing::ClientTest < MiniTest::Unit::TestCase

  def setup
    @base_url = 'http://example.com/sharing'
    @path     = '/'
  end

  def do_request(method, options={})
    client = TicketSharing::Client.new(@base_url, options[:token])
    response = client.send(method, @path, "{}")
    [client, response]
  end

  def test_a_successful_post_with_200_response
    expected_request = stub_request(:post, @base_url + @path)

    client, response = do_request(:post)
    assert client.success?
    assert_equal("200", response.code)
    assert !response.nil?

    assert_requested(expected_request)
  end

  def test_a_successful_post_with_ssl
    @base_url = 'https://example.com/sharing'

    expected_request = stub_request(:post, @base_url + @path)

    do_request(:post)

    assert_requested(expected_request)
  end

  def test_a_successful_post_with_201_response
    expected_request = stub_request(:post, @base_url + @path)
      .and_return(:status => 201)

    client, response = do_request(:post)
    assert client.success?
    assert_equal("201", response.code)

    assert_requested(expected_request)
  end

  def test_should_follow_redirects
    client = TicketSharing::Client.new('http://example.com/sharing')

    stub_request(:post, 'http://example.com/sharing/')
      .and_return(:status => 302, :headers => { 'Location' => 'https://example.com/sharing/' })
    stub_request(:post, 'https://example.com/sharing/')
      .and_return(:body => 'the final url', :status => 201)

    response = client.post('/', '')
    assert_equal('201', response.code)
    assert_equal('the final url', response.body)

    assert client.success?
  end

  def test_should_not_follow_more_than_x_redirects
    client = TicketSharing::Client.new('http://example.com/sharing')

    stub_request(:post, 'http://example.com/sharing/')
      .and_return(:status => 302, :headers => { 'Location' => 'http://example.com/sharing/' })

    assert_raises(TicketSharing::TooManyRedirects) do
      response = client.post('/', '')
    end
  end

  def test_a_failing_post_with_400_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => [400, 'Bad Request'])

    begin
      client, response = do_request(:post)
      flunk 'should raise an exception'
    rescue TicketSharing::Error => e
      assert_equal(%Q{400 "Bad Request"\n\n} + the_body, e.message)
    end
  end

  def test_a_failing_post_with_403_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => 403)

    client, response = do_request(:post)
    assert !client.success?
    assert_equal("403", response.code)
  end

  def test_a_failing_post_with_a_405_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => 405)

    client, response = do_request(:post)
    assert !client.success?
  end

  def test_a_failing_post_with_404_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => 404)

    client, response = do_request(:post)
    assert !client.success?
  end

  def test_a_failing_post_with_410_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => 410)

    client, response = do_request(:post)
    assert !client.success?
    assert_equal("410", response.code)
  end

  def test_a_failing_post_with_422_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => 422)

    client, response = do_request(:post)
    assert !client.success?
    assert_equal("422", response.code)
  end

  def test_a_failing_post_with_a_5xx_response
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(:body => the_body, :status => 500)

    client, response = do_request(:post)
    assert !client.success?
  end

  def test_a_successful_post_without_a_token
    expected_request = stub_request(:post, @base_url + @path).with do |request|
      request.headers['X-Ticket-Sharing-Token'] == nil
    end
    client, response = do_request(:post)
    assert client.success?
  end

  def test_a_successful_post_with_auth_token
    stub_request(:post, @base_url + @path)
      .with(headers: { 'X-Ticket-Sharing-Token' => 'the_token' })
    client, response = do_request(:post, :token => 'the_token')
    assert client.success?
  end

  def test_a_successful_put
    stub_request(:put, 'http://example.com/sharing/')
    client, response = do_request(:put)
    assert client.success?
  end

  def test_a_successful_put_with_auth_token
    stub_request(:post, 'http://example.com/sharing/')
      .with(headers: { 'X-Ticket-Sharing-Token' => 'the_token' })
    client, response = do_request(:post, :token => 'the_token')
    assert client.success?
  end

  def test_a_successful_delete
    stub_request(:delete, 'http://example.com/sharing/tickets/t1')

    client = TicketSharing::Client.new('http://example.com/sharing/')
    client.delete('tickets/t1')
  end

end
