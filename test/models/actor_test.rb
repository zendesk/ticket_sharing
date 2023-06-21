require 'test_helper'
require 'ticket_sharing/actor'

describe TicketSharing::Actor do
  let(:described_class) { TicketSharing::Actor }

  it 'initializes from a hash' do
    hash = { 'uuid' => 'ba90d6', 'role' => 'staff' }
    actor = described_class.new(hash)
    assert_equal 'staff', actor.role
  end

  it 'implements to_json' do
    hash = { 'uuid' => 'ba90d6', 'name' => 'Joe' }
    actor = described_class.new(hash)

    actual = actor.to_json
    assert_match(/ba90d6/, actual)
    assert_match(/Joe/, actual)
  end

  it 'responds to actor' do
    actor = described_class.new
    refute_predicate actor, :agent?

    actor.role = 'agent'
    assert_predicate actor, :agent?
  end

end
