require File.dirname(__FILE__) + '/../test_helper'
require 'seher_controller'

# Re-raise errors caught by the controller.
class SeherController; def rescue_action(e) raise e end; end

class SeherControllerTest < Test::Unit::TestCase

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = SeherController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
