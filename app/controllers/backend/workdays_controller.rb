class Backend::WorkdaysController < Backend::BackendController


  def index
    @workday = current_inventory_pool.get_workday
  end
  
  def close
    @workday = current_inventory_pool.get_workday
    @workday.update_attribute(params[:day], false) if Workday::DAYS.include?(params[:day])
    render :action => 'index'
  end
  
  def open
    @workday = current_inventory_pool.get_workday
    @workday.update_attribute(params[:day], true) if Workday::DAYS.include?(params[:day])
    render :action => 'index'
  end
end