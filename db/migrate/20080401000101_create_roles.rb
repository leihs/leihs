class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.integer :parent_id  # acts_as_nested_set
      t.integer :lft        # acts_as_nested_set
      t.integer :rgt        # acts_as_nested_set

      t.string :name
    end

  end

  def self.down
    drop_table :roles
  end
end
