require 'test_helper'
require 'ticket_sharing/request'

class TicketSharing::RequestTest < MiniTest::Unit::TestCase

  def test_a_new_raw_request_should_have_a_json_accept_header
    request = TicketSharing::Request.new(Net::HTTP::Post,
      'http://example.com/sharing', 'body')

    raw_request = request.new_raw_request
    assert_equal('application/json', raw_request['Accept'])
  end

end
