require File.dirname(__FILE__) + '/../test_helper'
require 'stores_controller'

# Re-raise errors caught by the controller.
class StoresController; def rescue_action(e) raise e end; end

class StoresControllerTest < Test::Unit::TestCase
  def setup
    @controller = StoresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
