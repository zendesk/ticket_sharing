require 'spec_helper'
require 'ticket_sharing/client'

describe TicketSharing::Client do

  before do
    @base_url = 'http://example.com/sharing'
    @path     = '/'
  end

  def do_request(method, options={})
    client = described_class.new(@base_url, options[:token])
    response = client.send(method, @path, '{}')
    [client, response]
  end

  it 'handles a successful post with 200 response' do
    expected_request = stub_request(:post, @base_url + @path)

    client, response = do_request(:post)
    expect(client).to be_success
    expect(response).to_not be_nil
    expect(response.code).to eq('200')

    expect(expected_request).to have_been_requested
  end

  it 'handles a successful post with ssl' do
    @base_url = 'https://example.com/sharing'

    expected_request = stub_request(:post, @base_url + @path)

    do_request(:post)

    expect(expected_request).to have_been_requested
  end

  it 'handles a successful post with 201 response' do
    expected_request = stub_request(:post, @base_url + @path)
      .and_return(status: 201)

    client, response = do_request(:post)
    expect(client).to be_success
    expect(response.code).to eq('201')

    expect(expected_request).to have_been_requested
  end

  it 'follows redirects' do
    client = described_class.new('http://example.com/sharing')

    stub_request(:post, 'http://example.com/sharing/')
      .and_return(status: 302, headers: { 'Location' => 'https://example.com/sharing/' })
    stub_request(:post, 'https://example.com/sharing/')
      .and_return(body: 'the final url', status: 201)

    response = client.post('/', '')
    expect(response.code).to eq('201')
    expect(response.body).to eq('the final url')

    expect(client).to be_success
  end

  it 'nots follow_more_than_x_redirects' do
    client = described_class.new('http://example.com/sharing')

    stub_request(:post, 'http://example.com/sharing/')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/' })

    expect {
      response = client.post('/', '')
    }.to raise_error(TicketSharing::TooManyRedirects)
  end

  it 'handles a failing post with 400 response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: [400, 'Bad Request'])

    expect {
      client, response = do_request(:post)
    }.to raise_error(TicketSharing::Error, %Q{400 "Bad Request"\n\n} + the_body)
  end

  it 'handles a failing post with 403 response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: 403)

    client, response = do_request(:post)
    expect(client).to_not be_success
    expect(response.code).to eq('403')
  end

  it 'handles a failing post with a 405 response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: 405)

    client, response = do_request(:post)
    expect(client).to_not be_success
  end

  it 'handles a failing post with 404 response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: 404)

    client, response = do_request(:post)
    expect(client).to_not be_success
  end

  it 'handles a failing post with 410 response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: 410)

    client, response = do_request(:post)
    expect(client).to_not be_success
    expect(response.code).to eq('410')
  end

  it 'handles a failing post with 422 response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: 422)

    client, response = do_request(:post)
    expect(client).to_not be_success
    expect(response.code).to eq('422')
  end

  it 'handles a failing post with a 5xx response' do
    the_body = "{'error': 'the error'}"
    stub_request(:post, @base_url + @path)
      .and_return(body: the_body, status: 500)

    client, response = do_request(:post)
    expect(client).to_not be_success
  end

  it 'handles a successful post without a token' do
    expected_request = stub_request(:post, @base_url + @path).with do |request|
      request.headers['X-Ticket-Sharing-Token'] == nil
    end
    client, response = do_request(:post)
    expect(client).to be_success
  end

  it 'handles a successful post with auth token' do
    stub_request(:post, @base_url + @path)
      .with(headers: { 'X-Ticket-Sharing-Token' => 'the_token' })
    client, response = do_request(:post, token: 'the_token')
    expect(client).to be_success
  end

  it 'handles a successful put' do
    stub_request(:put, 'http://example.com/sharing/')
    client, response = do_request(:put)
    expect(client).to be_success
  end

  it 'handles a successful put with auth token' do
    stub_request(:post, 'http://example.com/sharing/')
      .with(headers: { 'X-Ticket-Sharing-Token' => 'the_token' })
    client, response = do_request(:post, token: 'the_token')
    expect(client).to be_success
  end

  it 'handles a successful delete' do
    stub_request(:delete, 'http://example.com/sharing/tickets/t1')

    client = described_class.new('http://example.com/sharing/')
    client.delete('tickets/t1')
  end

end
