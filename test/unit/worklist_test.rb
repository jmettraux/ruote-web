
require File.dirname(__FILE__) + '/../test_helper'

class WiStoreTest < Test::Unit::TestCase

  fixtures :wi_stores, :store_permissions, :users, :groups, :workitems

  def test_find_store_names

    wl = Worklist.new(users(:alice))

    assert_equal [ "alpha", "bravo", "users" ], wl.store_names
  end

  def test_alice

    wl = Worklist.new(users(:alice))

    assert wl.permission("alpha").may_read?

    assert_equal 4, wl.workitems.size
    assert_equal 1, wl.workitems('alpha').size
    assert_equal 1, wl.workitems('users').size
  end

  def test_bob

    wl = Worklist.new(users(:bob))

    assert wl.permission("alpha").may_read?
    assert ( ! wl.permission("alpha").may_write?)

    assert_equal 2, wl.workitems.size
    assert_equal 1, wl.workitems('alpha').size
    assert_equal 1, wl.workitems('users').size
  end

  protected

    #def snoop (wl)
    #  p [ :user, wl.user.name ]
    #  p [ :all, wl.workitems.collect { |wi| wi_to_h(wi) } ]
    #  p [ :alpha, wl.workitems('alpha').collect { |wi| wi_to_h(wi) } ]
    #  p [ :bravo, wl.workitems('bravo').collect { |wi| wi_to_h(wi) } ]
    #end
    #def wi_to_h (wi)
    #    { :id => wi.id, :pn => wi.participant_name, :sn => wi.store_name }
    #end

end
