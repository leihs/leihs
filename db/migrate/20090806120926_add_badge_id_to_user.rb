class AddBadgeIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :badge_id, :string
  end

  def self.down
    remove_column :users, :badge_id
  end
end
