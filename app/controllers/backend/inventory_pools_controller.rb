class Backend::InventoryPoolsController < Backend::BackendController
    
  def index
    respond_to do |format|
      format.html
    end
  end

  def show(date = params[:date])
    @date = date ? Date.parse(date) : Date.today
    redirect_to backend_inventory_pool_path(current_inventory_pool) if @date < Date.today
  end
  
  def new
    @inventory_pool = InventoryPool.new
    render :action => 'edit'
  end

  def edit
    @holidays = current_inventory_pool.holidays.reject{|h| h.end_date < Date.today}.sort_by(&:start_date)
    @inventory_pool = InventoryPool.find params[:id]
    @inventory_pool.attributes = params[:inventory_pool] if params[:inventory_pool]
  end

  def create
    @inventory_pool = InventoryPool.new

    params[:inventory_pool][:print_contracts] ||= "false" # unchecked checkboxes are *not* being sent
    params[:inventory_pool][:email] = nil if params[:inventory_pool][:email].blank?
    if @inventory_pool.update_attributes(params[:inventory_pool])
      flash[:notice] = _("Inventory pool successfully created")
      redirect_to edit_backend_inventory_pool_path(@inventory_pool)
    else
      flash[:error] = @inventory_pool.errors.full_messages.uniq # TODO: set @current_inventory_pool here? See Backend::BackendController#current_inventory_pool
      redirect_to new_backend_inventory_pool_path(@inventory_pool)
    end

    current_user.access_rights.create(:role => Role.where(:name => 'manager').first,
                                      :inventory_pool => @inventory_pool,
                                      :access_level => 3) unless @inventory_pool.new_record?
  end

  # TODO: this mess needs to be untangled and split up into functions called by new/create/update
  def update
    @inventory_pool ||= InventoryPool.find(params[:id]) 
    params[:inventory_pool][:print_contracts] ||= "false" # unchecked checkboxes are *not* being sent
    params[:inventory_pool][:email] = nil if params[:inventory_pool][:email].blank?
    params[:inventory_pool][:workday_attributes].delete ""
    if @inventory_pool.update_attributes(params[:inventory_pool])
      flash[:notice] = _("Inventory pool successfully updated")
      redirect_to edit_backend_inventory_pool_path(@inventory_pool)
    else
      redirected_params = {name: params[:inventory_pool][:name], shortname: params[:inventory_pool][:shortname]}
      redirect_to edit_backend_inventory_pool_path(@current_inventory_pool, inventory_pool: redirected_params), flash: {error: @inventory_pool.errors.full_messages.uniq}
    end
  end

  def destroy
    @inventory_pool = InventoryPool.find(params[:id]) 

    if @inventory_pool.items.empty?
      
      @inventory_pool.destroy
      respond_to do |format|
        format.html { redirect_to backend_inventory_pools_path }
      end
    else
      # TODO 0607 ajax delete
      @inventory_pool.errors.add(:base, _("The Inventory Pool must be empty"))
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def workload(date = params[:date].try{|x| Date.parse(x)})
    today_and_next_4_days = [date] 
    4.times { today_and_next_4_days << current_inventory_pool.next_open_date(today_and_next_4_days[-1] + 1.day) }
    
    grouped_visits = current_inventory_pool.visits.includes(:user => {}, :contract_lines => [:model, :contract]).where("date <= ?", today_and_next_4_days.last).group_by {|x| [x.action, x.date] }
    
    chart_data = today_and_next_4_days.map do |day|
      day_name = (day == Date.today) ? _("Today") : l(day, :format => "%a %d.%m")
      take_back_visits_on_day = grouped_visits[["take_back", day]] || []
      take_back_workload = take_back_visits_on_day.size * 4 + take_back_visits_on_day.sum(&:quantity)
      hand_over_visits_on_day = grouped_visits[["hand_over", day]] || []
      hand_over_workload = hand_over_visits_on_day.size * 4 + hand_over_visits_on_day.sum(&:quantity)
      [[take_back_workload, hand_over_workload],
        {:name => day_name,
         :value => "#{take_back_visits_on_day.size+hand_over_visits_on_day.size} Visits<br/>#{take_back_visits_on_day.sum(&:quantity)+hand_over_visits_on_day.sum(&:quantity)} Items"}]
    end

    respond_to do |format|
      format.json { render :json => chart_data }
    end
  end
end
