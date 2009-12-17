class AddIndicesToRoles < ActiveRecord::Migration

  def self.up    

    change_table  :roles do |t|
      t.index     :parent_id
      t.index     :lft
      t.index     :rgt
      t.index     :name
    end

  end
  
  def self.down
  end
end
