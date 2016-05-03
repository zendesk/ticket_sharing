require 'spec_helper'
require 'ticket_sharing/request'

describe TicketSharing::Request do
  it 'uses correct headers' do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .with(headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })

    described_class.new.request(:post, 'http://example.com/sharing')

    expect(expected_request).to have_been_requested
  end

  it 'can set headers' do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .with(headers: { 'X-Foo' => '1234' })

    described_class.new.request(:post, 'http://example.com/sharing', headers: {'X-Foo' => '1234'})

    expect(expected_request).to have_been_requested
  end

  it 'fails with too many redirects' do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing' })

    expect {
      described_class.new.request(:post, 'http://example.com/sharing', body: 'body')
    }.to raise_error(TicketSharing::TooManyRedirects)

    expect(expected_request).to have_been_requested.times(3)
  end

  it 'follows redirects' do
    expected_request1 = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/1' })
    expected_request2 = stub_request(:post, 'http://example.com/sharing/1')

    response = described_class.new.request(:post, 'http://example.com/sharing', body: 'body')
    expect(response.code).to eq('200')

    expect(expected_request1).to have_been_requested
    expect(expected_request2).to have_been_requested
  end

  it 'resets headers on redirect request' do
    expected_request1 = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/1' })
    expected_request2 = stub_request(:post, 'http://example.com/sharing/1')
      .with(headers: { 'X-Foo' => '1' })

    response = described_class.new.request(:post, 'http://example.com/sharing', headers: {'X-Foo' => '1'})
    expect(response.code).to eq('200') # got redirected ?

    expect(expected_request1).to have_been_requested
    expect(expected_request2).to have_been_requested
  end

  it 'does not verify ssl with non verify option' do
    expected_request = stub_request(:post, 'https://example.com/sharing')
    expect_any_instance_of(Net::HTTP).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

    described_class.new.request(:post, 'https://example.com/sharing', ssl: {verify: false})

    expect(expected_request).to have_been_requested
  end

  it 'does not set special verify_mode without option' do
    expected_request = stub_request(:post, 'https://example.com/sharing')
    expect_any_instance_of(Net::HTTP).to receive(:verify_mode=).never

    described_class.new.request(:post, 'https://example.com/sharing')

    expect(expected_request).to have_been_requested
  end
end
