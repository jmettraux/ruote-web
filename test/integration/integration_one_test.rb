
require "#{File.dirname(__FILE__)}/../test_helper"

require 'test/integration/integration_base'


class IntegrationOneTest < ActionController::IntegrationTest
  include IntegrationBase

  fixtures :users, :launch_permissions, :wi_stores

  TEST_PDEF = "public/process_definitions/test.rb"

  def setup

    $openwferu_engine.reload_store_participants
      #
      # forces a reload of the store participants
      # (the fixtures seem to be loaded after the engine has been 
      # initialized)

    File.open(TEST_PDEF, "w") do |f|

      f.puts "class TestDefinition < OpenWFE::ProcessDefinition"
      f.puts "    sequence do"
      f.puts "        alpha"
      f.puts "    end"
      f.puts "end"
    end
  end

  def teardown

    File.delete(TEST_PDEF) if File.exist?(TEST_PDEF)
  end

  def test_launch_bad

    alice = new_session_as :alice
    alice.post "launchp/launch/9", nil, :referer => "launchp"
    alice.assert_response :redirect
    assert_equal alice.flash[:notice], "launch permission not found"
  end

  def test_launch_good

    lp = launch_permissions :lp1

    alice = new_session_as(:alice)
    alice.launches lp.id

    #puts alice.session[:launched_fei]

    sleep 1
  end

  def test_participants
    
    assert_not_nil $openwferu_engine.get_participant("alpha")
    assert_not_nil $openwferu_engine.get_participant("bravo")
    #assert_not_nil $openwferu_engine.get_participant("user_.*")
  end

  def test_locks

    wi = OpenWFE::Extras::Workitem.new
    wi.fei = "(fei 0.9.14 engine/engine public/process_definitions/test.rb SimpleSequence 0 20070827-desogihiso bravo 0.0.3)"
    wi.store_name = "bravo"
    wi.save!

    alice = new_session_as(:alice)
    bob = new_session_as(:bob)

    alice.enters_edition(wi.id)

    bob.enters_edition_and_it_fails(wi.id)

    alice.cancels_edition(wi.id)

    bob.enters_edition(wi.id)
  end

end
