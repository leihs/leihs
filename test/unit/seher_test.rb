require File.dirname(__FILE__) + '/../test_helper'

class SeherTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_pruefe_benachrichtigungen
		ueberfaellige = Seher.pruefe_benachrichtigungen
    assert ueberfaellige.is_a?( Array )
  end
end
