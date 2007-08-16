require File.dirname(__FILE__) + '/../test_helper'
require 'reservieren_controller'

# Re-raise errors caught by the controller.
class ReservierenController; def rescue_action(e) raise e end; end

class ReservierenControllerTest < Test::Unit::TestCase

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = ReservierenController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end

end
