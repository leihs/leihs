class Manage::PartitionsController < Manage::ApplicationController

  def index
    model_ids = params[:model_ids].try :map, &:to_i
    @partitions = \
      Partition.with_generals(model_ids: model_ids,
                              inventory_pool_id: current_inventory_pool.id)
  end

end
