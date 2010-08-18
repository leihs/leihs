class RemoveIsBorrowableAllowed < ActiveRecord::Migration
  def self.up
    remove_column(:items, :is_borrowable_allowed)
    # active model seem not to notice that some column has gone missing
    Item.reset_column_information
  end

  def self.down
    add_column(:items, :is_borrowable_allowed, :boolean, :default => false)
  end
end
