class Manage::OptionsController < Manage::ApplicationController

  def index
    @options = Option.filter params, current_inventory_pool
    set_pagination_header(@options) unless params[:paginate] == "false"
  end

  def new
    @option ||= Option.new
  end

  def create
    @option = Option.new(:inventory_pool => current_inventory_pool)
    if @option.update_attributes(params[:option])
      redirect_to manage_inventory_path(current_inventory_pool), flash: {success: _("Option saved")}
    else
      flash[:error] = @option.errors.full_messages.uniq.join(", ")
      render :new
    end
  end

  def update
    @option = current_inventory_pool.options.find params[:id]
    if @option.update_attributes(params[:option])
      redirect_to manage_inventory_path(current_inventory_pool), flash: {success: _("Option saved")}
    else
      flash[:error] = @option.errors.full_messages.uniq.join(", ")
      render :edit
    end
  end

  def edit
    @option ||= current_inventory_pool.options.find params[:id]
  end
      
end
