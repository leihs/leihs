class RefactorItems < ActiveRecord::Migration
  def self.up
    rename_column(:items, :for_rental, :is_borrowable_allowed)
    change_column_default(:items, :is_borrowable_allowed, false)
    change_column_default(:items, :is_borrowable, false)
  end

  def self.down
    change_column_default(:items, :is_borrowable, true)
    change_column_default(:items, :is_borrowable_allowed, nil)
    rename_column(:items, :is_borrowable_allowed, :for_rental)
  end
end
