class Address < ActiveRecord::Base

  geocoded_by :singleline_address
  
  before_save :geocode

  validates_uniqueness_of :street, :scope => [:zip_code, :city, :country_code]
  
  def to_s
    multiline_address
  end
  
  def multiline_address
    [street, zip_code, city, country].compact.join('\r\n')
  end
  
  def singleline_address
    [street, zip_code, city, country].compact.join(', ')
  end

  def country
    # TODO translate
    country_code
  end
  
  def coordinates
    if latitude.nil? or longitude.nil?
      geocode
    else
      [latitude, longitude]
    end
  end

end
