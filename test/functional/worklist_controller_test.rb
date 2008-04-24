
require File.dirname(__FILE__) + '/../test_helper'
require 'worklist_controller'

# Re-raise errors caught by the controller.
class WorklistController; def rescue_action(e) raise e end; end

class WorklistControllerTest < Test::Unit::TestCase
  def setup
    @controller = WorklistController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
