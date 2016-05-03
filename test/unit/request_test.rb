require File.expand_path('../../test_helper', __FILE__)
require 'ticket_sharing/request'

describe TicketSharing::Request do
  it "uses correct headers" do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .with(headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })

    TicketSharing::Request.new.request(:post, 'http://example.com/sharing')

    assert_requested(expected_request)
  end

  it "can set headers" do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .with(headers: { 'X-Foo' => '1234' })

    TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :headers => {'X-Foo' => '1234'})

    assert_requested(expected_request)
  end

  it "fails with too many redirects" do
    expected_request = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing' })

    assert_raises TicketSharing::TooManyRedirects do
      TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :body => "body")
    end

    assert_requested(expected_request, :times => 3)
  end

  it "follows redirects" do
    expected_request1 = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/1' })
    expected_request2 = stub_request(:post, 'http://example.com/sharing/1')

    response = TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :body => "body")
    response.code.to_i.must_equal 200

    assert_requested(expected_request1)
    assert_requested(expected_request2)
  end

  it "resets headers on redirect request" do
    expected_request1 = stub_request(:post, 'http://example.com/sharing')
      .and_return(status: 302, headers: { 'Location' => 'http://example.com/sharing/1' })
    expected_request2 = stub_request(:post, 'http://example.com/sharing/1')
      .with(headers: { 'X-Foo' => '1' })

    response = TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :headers => {"X-Foo" => "1"})
    response.code.to_i.must_equal 200 # got redirected ?

    assert_requested(expected_request1)
    assert_requested(expected_request2)
  end

  it "does not verify ssl with non verify option" do
    expected_request = stub_request(:post, 'https://example.com/sharing')
    Net::HTTP.any_instance.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

    TicketSharing::Request.new.request(:post, 'https://example.com/sharing', :ssl => {:verify => false})

    assert_requested(expected_request)
  end

  it "does not set special verify_mode without option" do
    expected_request = stub_request(:post, 'https://example.com/sharing')
    Net::HTTP.any_instance.expects(:verify_mode=).never

    TicketSharing::Request.new.request(:post, 'https://example.com/sharing')

    assert_requested(expected_request)
  end
end
