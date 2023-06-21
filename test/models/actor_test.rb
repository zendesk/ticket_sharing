require 'spec_helper'
require 'ticket_sharing/actor'

describe TicketSharing::Actor do
  it 'initializes from a hash' do
    hash = { 'uuid' => 'ba90d6', 'role' => 'staff' }
    actor = described_class.new(hash)
    expect(actor.role).to eq('staff')
  end

  it 'implements to_json' do
    hash = { 'uuid' => 'ba90d6', 'name' => 'Joe' }
    actor = described_class.new(hash)

    actual = actor.to_json
    expect(actual).to match(/ba90d6/)
    expect(actual).to match(/Joe/)
  end

  it 'responds to actor' do
    actor = described_class.new
    expect(actor).to_not be_agent

    actor.role = 'agent'
    expect(actor).to be_agent
  end

end
