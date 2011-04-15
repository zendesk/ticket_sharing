require 'test_helper'
require 'ticket_sharing/actor'

class ActorTest < MiniTest::Unit::TestCase

  def test_should_initialize_from_a_hash
    hash = { 'uuid' => 'ba90d6', 'role' => 'staff' }
    actor = TicketSharing::Actor.new(hash)
    assert_equal('staff', actor.role)
  end

  def test_should_implement_to_json
    hash = { 'uuid' => 'ba90d6', 'name' => 'Joe' }
    actor = TicketSharing::Actor.new(hash)

    actual = actor.to_json
    assert_match(/ba90d6/, actual)
    assert_match(/Joe/, actual)
  end

  def test_should_respond_to_actor
    actor = TicketSharing::Actor.new
    assert !actor.agent?

    actor.role = 'agent'
    assert actor.agent?
  end

end
