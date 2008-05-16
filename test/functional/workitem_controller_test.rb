
require File.dirname(__FILE__) + '/../test_helper'
require 'workitem_controller'

# Re-raise errors caught by the controller.
class WorkitemController; def rescue_action(e) raise e end; end

class WorkitemControllerTest < Test::Unit::TestCase

  def setup
    @controller = WorkitemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  #
  # a kind of digression, testing the filter_fields() method in the
  # workitem controller...
  #
  def test_filter_fields

    class << @controller
      public :filter_fields
    end

    wi = new_wi({ "a" => 1, "b" => 2, "_c" => 3, "_d" => 4 })

    f0, f1 = @controller.filter_fields(wi)

    assert_equal({"a"=>1, "b"=>2}, f0)
    assert_equal({"_c"=>3, "_d"=>4}, f1)
  end

  protected

    #
    # mocking...
    #
    def new_wi (h)

      o = Object.new
      class << o
        attr_accessor :h
        def fields_hash
          h
        end
      end
      o.h = h

      o
    end
end
