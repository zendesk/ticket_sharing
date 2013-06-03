require File.expand_path('../../test_helper', __FILE__)
require 'ticket_sharing/request'

describe TicketSharing::Request do
  it "uses correct headers" do
    FakeWeb.register_uri(:post, 'http://example.com/sharing', :body => "")
    TicketSharing::Request.new.request(:post, 'http://example.com/sharing')

    request = FakeWeb.last_request
    request['Content-Type'].must_equal 'application/json'
    request['Accept'].must_equal 'application/json'
  end

  it "can set headers" do
    FakeWeb.register_uri(:post, 'http://example.com/sharing', :body => "")
    TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :headers => {'X-Foo' => '1234'})

    request = FakeWeb.last_request
    request['X-Foo'].must_equal '1234'
  end

  it "fails with too many redirects" do
    FakeWeb.register_uri(:post, 'http://example.com/sharing', :response => redirect('http://example.com/sharing'))

    assert_raises TicketSharing::TooManyRedirects do
      TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :body => "body")
    end
  end

  it "follows redirects" do
    FakeWeb.register_uri(:post, 'http://example.com/sharing', :response => redirect('http://example.com/sharing/1'))
    FakeWeb.register_uri(:post, 'http://example.com/sharing/1', :status => 200)

    response = TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :body => "body")
    response.code.to_i.must_equal 200
  end

  it "resets headers on redirect request" do
    FakeWeb.register_uri(:post, 'http://example.com/sharing', :response => redirect('http://example.com/sharing/1'))
    FakeWeb.register_uri(:post, 'http://example.com/sharing/1', :status => 200)

    response = TicketSharing::Request.new.request(:post, 'http://example.com/sharing', :headers => {"X-Foo" => "1"})
    response.code.to_i.must_equal 200 # got redirected ?

    request = FakeWeb.last_request
    request['X-Foo'].must_equal '1'
  end

  it "does not verify ssl with non verify option" do
    FakeWeb.register_uri(:post, 'https://example.com/sharing', :body => "body")
    Net::HTTP.any_instance.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    TicketSharing::Request.new.request(:post, 'https://example.com/sharing', :ssl => {:verify => false})
  end

  it "does not set special verify_mode without option" do
    FakeWeb.register_uri(:post, 'https://example.com/sharing/1', :body => "body")
    Net::HTTP.any_instance.expects(:verify_mode=).never
    TicketSharing::Request.new.request(:post, 'https://example.com/sharing')
  end

  def redirect(url)
    redirect_response = Net::HTTPResponse.new('1.1', '302', 'Found')
    redirect_response['Location'] = url
    redirect_response
  end
end
