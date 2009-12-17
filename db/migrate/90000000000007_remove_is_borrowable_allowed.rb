class RemoveIsBorrowableAllowed < ActiveRecord::Migration
  def self.up
    remove_column(:items, :is_borrowable_allowed)
  end

  def self.down
    add_column(:items, :is_borrowable_allowed, :boolean, :default => false)
  end
end
