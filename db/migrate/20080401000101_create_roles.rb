class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.integer :parent_id  # acts_as_nested_set
      t.integer :lft        # acts_as_nested_set
      t.integer :rgt        # acts_as_nested_set

      t.string :name
    end

    r_a = Role.create(:name => "admin")
    
    r_im = Role.create(:name => "manager")
    r_im.move_to_child_of r_a
    
    r_s = Role.create(:name => "customer")
    r_s.move_to_child_of r_im

  end

  def self.down
    drop_table :roles
  end
end
