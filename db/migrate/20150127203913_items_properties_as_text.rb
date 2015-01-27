class ItemsPropertiesAsText < ActiveRecord::Migration
  def change

    change_column :items, :properties, :text # serialized

  end
end
