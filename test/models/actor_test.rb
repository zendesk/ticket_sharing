require 'test_helper'
require 'ticket_sharing/actor'

describe TicketSharing::Actor do
  let(:described_class) { TicketSharing::Actor }

  it 'initializes from a hash' do
    hash = { 'uuid' => 'ba90d6', 'role' => 'staff' }
    actor = described_class.new(hash)
    expect(actor.role).must_equal('staff')
  end

  it 'implements to_json' do
    hash = { 'uuid' => 'ba90d6', 'name' => 'Joe' }
    actor = described_class.new(hash)

    actual = actor.to_json
    expect(actual).must_match(/ba90d6/)
    expect(actual).must_match(/Joe/)
  end

  it 'responds to actor' do
    actor = described_class.new
    expect(actor).wont_be :agent?

    actor.role = 'agent'
    expect(actor).must_be :agent?
  end

end
