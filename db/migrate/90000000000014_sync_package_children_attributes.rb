class SyncPackageChildrenAttributes < ActiveRecord::Migration
  def self.up
    Item.suspended_delta do
      Item.all.each do |item|
        item.update_children_attributes
      end
    end
  end

  def self.down
  end
end
