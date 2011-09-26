require 'test_helper'
require 'ticket_sharing/request'

class TicketSharing::RequestTest < MiniTest::Unit::TestCase

  def test_a_new_raw_request_should_have_a_json_accept_header
    request = TicketSharing::Request.new(Net::HTTP::Post,
      'http://example.com/sharing', 'body')

    raw_request = request.new_raw_request
    assert_equal('application/json', raw_request['Accept'])
  end

  def test_should_persist_token_for_redirects
    FakeWeb.register_uri(:post, 'http://example.com/sharing/', :body => '',
      :status => '302', :location => 'https://example.com/sharing/')
    FakeWeb.register_uri(:post, 'https://example.com/sharing/',
      :body => 'the final url', :status => '201')
    request = TicketSharing::Request.new(Net::HTTP::Post,
        'http://example.com/sharing/', 'body')
    raw_request = request.new_raw_request
    request.set_header("X-Ticket-Sharing-Token", "token")
    request.send!
    assert_equal "302", request.raw_response.code
    request.follow_redirect!
    assert_equal "token", request.raw_request['X-Ticket-Sharing-Token']
  end
end
