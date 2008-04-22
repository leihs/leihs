require File.dirname(__FILE__) + '/abstract_unit'

class TimeTest < Test::Unit::TestCase
  def test_valid_when_nil
    assert p.update_attributes!(:time_of_birth => nil, :time_of_death => nil, :time_of_death => nil)
  end
  
  def test_with_seconds
    { '03:45:22' => /03:45:22/, '09:10:27' => /09:10:27/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_12_hour_with_minute
    { '7.20pm' => /19:20:00/, ' 1:33 AM' => /01:33:00/, '11 28am' => /11:28:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_12_hour_without_minute
    { '11 am' => /11:00:00/, '7PM ' => /19:00:00/, ' 1Am' => /01:00:00/, '12pm' => /12:00:00/, '12.00pm' => /12:00:00/, '12am' => /00:00:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_24_hour
    { '22:00' => /22:00:00/, '10 23' => /10:23:00/, '01 01' => /01:01:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_24_hour_with_microseconds
    assert_update_and_match /12:23:56/, :time_of_birth => "12:23:56.169732"
    assert_equal 169732, p.time_of_birth.usec
    
    assert_update_and_match /12:23:56/, :time_of_birth => "12:23:56.15"
    assert_equal 15, p.time_of_birth.usec
  end
  
  def test_iso8601
    assert_update_and_match /12:03:28/, :time_of_birth => "2008-02-23T12:03:28"
  end
  
  def test_24_hour_with_invalid_microseconds
    assert_invalid_and_errors_match /invalid/, :time_of_birth => "12:23:11.1234567"
  end
  
  def test_time_objects
    { Time.gm(2006, 2, 2, 22, 30) => /22:30:00/, '2pm' => /14:00:00/, Time.gm(2006, 2, 2, 1, 3) => /01:03:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_invalid_formats
    ['1 PPM', 'lunchtime', '8..30', 'chocolate', '29am'].each do |value|
      assert !p.update_attributes(:time_of_birth => value)
    end
    assert_match /time/, p.errors[:time_of_birth]
  end
  
  def test_after
    assert_invalid_and_errors_match /must be after/, :time_of_death => '6pm'
    
    assert p.update_attributes!(:time_of_death => '8pm')
    assert p.update_attributes!(:time_of_death => nil, :time_of_birth => Time.gm(2001, 1, 1, 9))
    
    assert_invalid_and_errors_match /must be after/, :time_of_death => '7am'
  end
  
  def test_before
    assert_invalid_and_errors_match /must be before/, :time_of_birth => Time.now + 1.day
    assert p.update_attributes!(:time_of_birth => Time.now - 1)
  end
  
  def test_blank
    assert p.update_attributes!(:time_of_birth => " ")
    assert_nil p.time_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_valid_time
    assert_nothing_raised do
      p.update_attributes!('time_of_birth(1i)' => '3', 'time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '10')
    end
    
    assert_equal Time.local(2000, 1, 1, 3, 2, 10), p.time_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_invalid_time
    assert_nothing_raised do
      assert !p.update_attributes('time_of_birth(1i)' => '23', 'time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '77')
    end
    
    assert p.errors[:time_of_birth]
  end
  
  def test_incomplete_multi_parameter_attribute_assignment
    assert_nothing_raised do
      assert !p.update_attributes('time_of_birth(1i)' => '10')
    end
    
    assert p.errors[:time_of_birth]
  end
end
