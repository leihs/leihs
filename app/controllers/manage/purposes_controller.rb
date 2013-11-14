class Manage::PurposesController <  Manage::ApplicationController

  def index
    @purposes = Purpose.where(id: params[:purpose_ids]) if params[:purpose_ids]
  end

  def update
    line = current_inventory_pool.contract_lines.where(purpose_id: params[:purpose_id]).first
    if line
      line.purpose.update_attributes description: params[:description]
      render :status => :ok, :nothing => true
    end
  end

end
