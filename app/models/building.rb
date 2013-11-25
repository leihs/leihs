class Building < ActiveRecord::Base
  include BuildingModules::Filter
  
  def to_s
    "#{name} (#{code})"
  end
end
