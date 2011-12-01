# -*- encoding : utf-8 -*-
require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  test "availability" do
    Factory.create_minimal_setup
    assert true
  end
end
