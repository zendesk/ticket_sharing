require 'spec_helper'
require 'ticket_sharing/base'

describe TicketSharing::Base do

  it 'inherits fields list from ancestors' do
    klass1 = Class.new(described_class) do
      fields :foo, :bar
    end

    klass2 = Class.new(klass1)

    expect(klass1.new.field_list).to eq([:foo, :bar])
    expect(klass2.new.field_list).to eq([:foo, :bar])
  end

end
