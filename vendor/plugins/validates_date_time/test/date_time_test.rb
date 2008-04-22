require File.dirname(__FILE__) + '/abstract_unit'

class DateTimeTest < Test::Unit::TestCase
  def test_various_formats
    formats = {
      '2006-01-01 01:01:01' => /Jan 01 01:01:01 [\+-]?[\w ]+ 2006/,
      '2/2/06 7pm'          => /Feb 02 19:00:00 [\+-]?[\w ]+ 2006/,
      '10 AUG 04 6.23am'    => /Aug 10 06:23:00 [\+-]?[\w ]+ 2004/,
      '6 June 1981 10 10'   => /Jun 06 10:10:00 [\+-]?[\w ]+ 1981/,
      'September 01, 2007 06:10' => /Sep 01 06:10:00 [\+-]?[\w ]+ 2007/,
      '2007-02-23T12:03:28' => /Feb 23 12:03:28 [\+-]?[\w ]+ 2007/
    }
    
    formats.each do |value, result|
      assert_update_and_match result, :date_and_time_of_birth => value
    end
    
    with_us_date_format do
      formats.each do |value, result|
        assert_update_and_match result, :date_and_time_of_birth => value
      end
    end
  end
  
  def test_date_time_with_microseconds
    assert_update_and_match /Mar 20 09:22:50 [\+-]?[\w ]+ 2007/, :date_and_time_of_birth => "20 Mar 07 09:22:50.987654"
    assert_equal 987654, p.date_and_time_of_birth.usec
  end
  
  def test_invalid_formats
    ['29 Feb 06 1am', '1 Jan 06', '7pm'].each do |value|
      assert_invalid_and_errors_match /date time/, :date_and_time_of_birth => value
    end
  end
  
  def test_before_and_after_restrictions_parsed_as_date_times    
    assert_invalid_and_errors_match /before/, :date_and_time_of_birth => '2008-01-02 00:00:00'
    assert p.update_attributes!(:date_and_time_of_birth => '2008-01-01 01:01:00')
    
    assert_invalid_and_errors_match /after/, :date_and_time_of_birth => '1981-01-01 01:00am'
    assert p.update_attributes!(:date_and_time_of_birth => '1981-01-01 01:02am')
  end
  
  def test_multi_parameter_attribute_assignment_with_valid_date_times
    assert_nothing_raised do
      p.update_attributes!('date_and_time_of_birth(1i)' => '2006', 'date_and_time_of_birth(2i)' => '2', 'date_and_time_of_birth(3i)' => '20',
        'date_and_time_of_birth(4i)' => '23', 'date_and_time_of_birth(5i)' => '10', 'date_and_time_of_birth(6i)' => '40')
    end
    
    assert_equal Time.local(2006, 2, 20, 23, 10, 40), p.date_and_time_of_birth
    
    # Without second parameter
    assert_nothing_raised do
      p.update_attributes!('date_and_time_of_birth(1i)' => '2004', 'date_and_time_of_birth(2i)' => '3', 'date_and_time_of_birth(3i)' => '14',
        'date_and_time_of_birth(4i)' => '22', 'date_and_time_of_birth(5i)' => '20')
    end
    
    assert_equal Time.local(2004, 3, 14, 22, 20), p.date_and_time_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_invalid_date_time
    assert_nothing_raised do
      assert !p.update_attributes('date_and_time_of_birth(1i)' => '2006', 'date_and_time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '10',
        'date_and_time_of_birth(4i)' => '30', 'date_and_time_of_birth(5i)' => '88', 'date_and_time_of_birth(6i)' => '100')
    end
    
    assert p.errors[:date_and_time_of_birth]
  end
  
  def test_incomplete_multi_parameter_attribute_assignment
    assert_nothing_raised do
      assert !p.update_attributes('date_and_time_of_birth(1i)' => '2006', 'date_and_time_of_birth(2i)' => '1')
    end
    
    assert p.errors[:date_and_time_of_birth]
  end
end
