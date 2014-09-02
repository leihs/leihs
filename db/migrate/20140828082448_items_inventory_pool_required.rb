class ItemsInventoryPoolRequired < ActiveRecord::Migration
  def change

    execute("UPDATE items SET inventory_pool_id=owner_id WHERE inventory_pool_id IS NULL")
    execute("UPDATE items SET owner_id=inventory_pool_id WHERE owner_id IS NULL")

    items_without_inventory_pools = Item.where(inventory_pool_id: nil, owner_id: nil)
    if items_without_inventory_pools.exists?
      puts %Q(
        =================================================
        The following items are not assigned to any inventory_pool_id and owner_id:
        #{items_without_inventory_pools.map(&:id).join(', ')}
        Please fix them and run this migration again.
        =================================================
      )
      raise
    else
      change_column_null :items, :inventory_pool_id, false
      change_column_null :items, :owner_id, false
    end

  end
end
