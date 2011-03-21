class AddUserNameFieldToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :user_name, :string
  end

  def self.down
    remove_column :items, :user_name
  end
end
