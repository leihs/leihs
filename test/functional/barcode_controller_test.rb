require File.dirname(__FILE__) + '/../test_helper'
require 'barcode_controller'

# Re-raise errors caught by the controller.
class BarcodeController; def rescue_action(e) raise e end; end

class BarcodeControllerTest < Test::Unit::TestCase
  def setup
    @controller = BarcodeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
