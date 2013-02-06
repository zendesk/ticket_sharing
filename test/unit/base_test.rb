require 'test_helper'
require 'ticket_sharing/base'

class BaseTest < MiniTest::Unit::TestCase

  def test_field_list_from_ancestors
    klass1 = Class.new(TicketSharing::Base) do
      fields :foo, :bar
    end

    klass2 = Class.new(klass1)

    assert_equal([:foo, :bar], klass1.new.field_list)
    assert_equal([:foo, :bar], klass2.new.field_list)
  end

end
