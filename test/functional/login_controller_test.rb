require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup

    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_successful_login

    alice = users(:alice)
    post :index, :name => alice.name, :password => "alice"
    assert_redirected_to :controller => "stores", :action => "index"
    assert_equal alice.id, session[:user].id
  end

  def test_failed_login

    alice = users(:alice)
    post :index, :name => alice.name, :password => "nada"
    assert_template "index"
  end
end
