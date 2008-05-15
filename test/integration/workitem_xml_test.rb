
require "#{File.dirname(__FILE__)}/../test_helper"

require 'rexml/document'

class WorkitemXmlTest < ActionController::IntegrationTest

  class Def0 < OpenWFE::ProcessDefinition 
    sequence do
      participant :ref => :testp
    end
  end

  def test_0

    $openwferu_engine.ac[:definition_in_launchitem_allowed] = true

    $openwferu_engine.register_participant :testp do |workitem|
      assert_equal workitem.xml_stuff.class, REXML::Text
      assert_equal workitem.xml_stuff.to_s, 'whatever'
    end

    li = OpenWFE::LaunchItem.new Def0
    li.xml_stuff = REXML::Text.new "whatever"
    fei = $openwferu_engine.launch li
    $openwferu_engine.wait_for fei
  end
end

