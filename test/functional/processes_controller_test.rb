
require File.dirname(__FILE__) + '/../test_helper'
require 'processes_controller'

# Re-raise errors caught by the controller.
class ProcessesController; def rescue_action(e) raise e end; end

class ProcessesControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProcessesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
