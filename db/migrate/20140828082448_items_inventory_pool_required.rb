class ItemsInventoryPoolRequired < ActiveRecord::Migration
  def change

    execute("UPDATE items SET inventory_pool_id=owner_id WHERE inventory_pool_id IS NULL")

    change_column_null :items, :inventory_pool_id, false

  end
end
