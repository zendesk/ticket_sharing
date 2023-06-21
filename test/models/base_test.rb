require 'test_helper'
require 'ticket_sharing/base'

describe TicketSharing::Base do

  it 'inherits fields list from ancestors' do
    klass1 = Class.new(TicketSharing::Base) do
      fields :foo, :bar
    end

    klass2 = Class.new(klass1)

    assert_equal [:foo, :bar], klass1.new.field_list
    assert_equal [:foo, :bar], klass2.new.field_list
  end

end
