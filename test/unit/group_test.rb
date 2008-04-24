
require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase

  fixtures :users, :groups

  def test_implicit_group

    u = User.new
    u.name = "nemo"
    
    l = Group.find_groups(u)
    assert_equal [ "nemo" ], l
  end

  def test_alice

    assert_equal [ "sales", "alice" ], Group.find_groups(users(:alice))
  end
end
