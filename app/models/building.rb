class Building < ActiveRecord::Base
  
  def to_s
    "#{name} (#{code})"
  end
end
