require File.dirname(__FILE__) + '/abstract_unit'

class DateTest < Test::Unit::TestCase
  def test_valid_when_nil
    assert p.update_attributes!(:date_of_birth => nil, :date_of_death => nil)
  end
  
  def test_date_required
    assert_invalid_and_errors_match /invalid/, :required_date => ""
  end
  
  # Test 1/1/06 format
  def test_first_format
    { '1/1/01'  => '2001-01-01', '29/10/2005' => '2005-10-29', '8\12\63' => '1963-12-08',
      '07/06/2006' => '2006-06-07', '11\1\06' => '2006-01-11', '10.6.05' => '2005-06-10' }.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  # Test 1 Jan 06 and 1 January 06 formats
  def test_second_format
    { '19 Mar 60'    => '1960-03-19', '22 dec 1985'      => '1985-12-22',
      '24 August 00' => '2000-08-24', '25 December 1960' => '1960-12-25'}.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  # Test February 4 2006 formats
  def test_third_format
    { 'february 4 06' => '2006-02-04', 'DECember 25 1850' => '1850-12-25', 'February 5, 2006' => '2006-02-05' }.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  def test_iso_format
    { '2006-01-01' => '2006-01-01', '1900-04-22' => '1900-04-22',
      '2008-03-04T20:33:41' => '2008-03-04' }.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  def test_format_without_validation
    assert_equal Date.new(2005, 12, 11).to_s, Person.new(:date_of_birth => "11/12/05").date_of_birth.to_s
  end
  
  def test_invalid_formats
    ['aksjhdaksjhd', 'meow', 'chocolate',
     '221 jan 05', '21 JAN 001', '1 Jaw 00', '1 Febrarary 2003', '30/2/06',
     '1/2/3/4', '11/22/33', '10/10/990', '189 /1 /9', '12\ f m'].each do |value|
      assert_invalid_and_errors_match /invalid/,  :date_of_birth => value
    end
  end
  
  def test_date_objects
    assert_update_and_equal '1963-04-05', :date_of_birth => Date.new(1963, 4, 5)
  end
  
  def test_before_and_after
    p.update_attributes!(:date_of_death => '1950-01-01')
    assert_invalid_and_errors_match /before/, :date_of_death => (Date.today + 1).to_s
    assert_invalid_and_errors_match /before/, :date_of_death => Date.new(2030, 1, 1)
    
    p.update_attributes!(:date_of_birth => '1950-01-01', :date_of_death => nil)
    assert_invalid_and_errors_match /after/, :date_of_death => '1950-01-01'
    assert p.update_attributes!(:date_of_death => Date.new(1951, 1, 1))
  end
  
  def test_before_and_after_with_custom_message
    assert_invalid_and_errors_match /avant/, :date_of_arrival => 2.years.from_now, :date_of_departure => 2.years.ago
    assert_invalid_and_errors_match /apres/, :date_of_arrival => '1792-03-03'
  end
  
  def test_dates_with_unknown_year
    assert p.update_attributes!(:date_of_birth => '9999-12-11')
    assert p.update_attributes!(:date_of_birth => Date.new(9999, 1, 1))
  end
  
  def test_us_date_format
    with_us_date_format do
      {'1/31/06'  => '2006-01-31', '28 Feb 01'  => '2001-02-28',
       '10/10/80' => '1980-10-10', 'July 4 1960' => '1960-07-04',
       '2006-03-20' => '2006-03-20'}.each do |value, result|
        assert_update_and_equal result, :date_of_birth => value
      end
    end
  end
  
  def test_blank
    assert p.update_attributes!(:date_of_birth => " ")
    assert_nil p.date_of_birth
  end
  
  def test_conversion_of_restriction_result
    assert_invalid_and_errors_match /Date of birth/, :date_of_death => Date.new(2001, 1, 1), :date_of_birth => Date.new(2005, 1, 1)
  end
  
  def test_multi_parameter_attribute_assignment_with_valid_date
    assert_nothing_raised do
      p.update_attributes!('date_of_birth(1i)' => '2006', 'date_of_birth(2i)' => '2', 'date_of_birth(3i)' => '10')
    end
    
    assert_equal Date.new(2006, 2, 10), p.date_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_invalid_date
    assert_nothing_raised do
      assert !p.update_attributes('date_of_birth(1i)' => '2006', 'date_of_birth(2i)' => '2', 'date_of_birth(3i)' => '30')
    end
    
    assert p.errors[:date_of_birth]
  end
  
  def test_incomplete_multi_parameter_attribute_assignment
    assert_nothing_raised do
      assert !p.update_attributes('date_of_birth(1i)' => '2006', 'date_of_birth(2i)' => '1', 'date_of_birth(3i)' => '')
    end
    
    assert p.errors[:date_of_birth]
  end
  
  def test_compatibility_with_old_namespace
    original_format = ValidatesDateTime.us_date_format
    
    assert_equal ValidatesDateTime.us_date_format, ActiveRecord::Validations::DateTime.us_date_format
    
    ActiveRecord::Validations::DateTime.us_date_format = 123
    assert_equal 123, ValidatesDateTime.us_date_format
  ensure
    ValidatesDateTime.us_date_format = original_format
  end
end
