class AddPropertiesToItems < ActiveRecord::Migration
  def change
    add_column :items, :properties, :string, :limit => 2048
  end
end
