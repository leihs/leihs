module Json
  module InventoryPoolHelper

    def hash_for_inventory_pool(inventory_pool, with = nil)
      h = {
        id: inventory_pool.id,
        name: inventory_pool.to_s
      }    
      
      if with ||= nil
        if with[:address] and not inventory_pool.address.blank?
          h[:address] = hash_for inventory_pool.address
        end
        if with[:closed_days]
          h[:closed_days] = inventory_pool.workday.closed_days
        end
        if with[:holidays]
          h[:holidays] = inventory_pool.holidays.future.as_json(:except => [:id, :inventory_pool_id])
        end
      end
      
      h
    end
  end
end
      