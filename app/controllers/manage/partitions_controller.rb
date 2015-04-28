class Manage::PartitionsController < Manage::ApplicationController
  
  def index
    @partitions = current_inventory_pool.partitions_with_generals.where(model_id: params[:model_ids])
  end

end