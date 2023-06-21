require 'test_helper'
require 'ticket_sharing/request'
require 'mocha/minitest'

describe TicketSharing::Request do
  let(:described_class) { TicketSharing::Request }

  it 'uses correct headers' do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .with(headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })

    described_class.new.request(:post, 'http://example.com/sharing')

    assert_request_requested expected_request
  end

  it 'can set headers' do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .with(headers: { 'X-Foo' => '1234' })

    described_class.new.request(:post, 'http://example.com/sharing', headers: {'X-Foo' => '1234'})

    assert_request_requested expected_request
  end

  it 'fails with too many redirects' do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing' })

    assert_raises TicketSharing::TooManyRedirects do
      described_class.new.request(:post, 'http://example.com/sharing', body: 'body')
    end

    assert_request_requested expected_request, times: 3
  end

  it 'follows redirects' do
    expected_request1 = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/1' })
    expected_request2 = stub_request(:post, 'http://example.com/sharing/1')

    response = described_class.new.request(:post, 'http://example.com/sharing', body: 'body')
    assert_equal 200, response.status

    assert_request_requested expected_request1
    assert_request_requested expected_request2
  end

  it 'resets headers on redirect request' do
    expected_request1 = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/1' })
    expected_request2 = stub_request(:post, 'http://example.com/sharing/1')
      .with(headers: { 'X-Foo' => '1' })

    response = described_class.new.request(:post, 'http://example.com/sharing', headers: {'X-Foo' => '1'})
    assert_equal 200, response.status # got redirected ?

    assert_request_requested expected_request1
    assert_request_requested expected_request2
  end

  it 'does not verify ssl with non verify option' do
    expected_request = stub_request(:post, 'https://example.com/sharing')
    Net::HTTP.any_instance.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

    described_class.new.request(:post, 'https://example.com/sharing', ssl: {verify: false})

    assert_request_requested expected_request
  end

  it 'set verify_mode to VERIFY_PEER without option' do
    expected_request = stub_request(:post, 'https://example.com/sharing')
    Net::HTTP.any_instance.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)

    described_class.new.request(:post, 'https://example.com/sharing')

    assert_request_requested expected_request
  end
end
