module Json
  module PartitionHelper

    def hash_for_partition(partition, with = nil)
      h = {
        id: partition.id,
        model_id: partition.model_id,
        inventory_pool_id: partition.inventory_pool_id,
        quantity: partition.quantity
      }

      if with[:model]
        h[:model] = hash_for partition.model, with[:model]
      end

      if with[:group]
        h[:group] = hash_for partition.group, with[:group]
      end

      h
    end

  end
end
