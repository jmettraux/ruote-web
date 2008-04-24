require File.dirname(__FILE__) + '/../test_helper'
require 'launchp_controller'

# Re-raise errors caught by the controller.
class LaunchpController; def rescue_action(e) raise e end; end

class LaunchpControllerTest < Test::Unit::TestCase

  #fixtures :users

  def setup

    @controller = LaunchpController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_nada
    assert true
  end
end
