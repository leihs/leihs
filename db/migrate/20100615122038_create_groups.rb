class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string     :name
      t.belongs_to :inventory_pool

      t.timestamps
    end

    create_table :groups_users, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :group
    end
  end

  def self.down
    drop_table :groups
    drop_table :groups_users
  end
end
