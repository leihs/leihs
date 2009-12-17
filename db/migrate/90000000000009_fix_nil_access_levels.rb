class FixNilAccessLevels < ActiveRecord::Migration

  def self.up    

    AccessRight.update_all({:access_level => 1}, {:role_id => Role.find_by_name('lending manager'), :access_level => nil})

  end
  
  def self.down
  end
end
