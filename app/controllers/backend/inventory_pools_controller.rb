class Backend::InventoryPoolsController < Backend::BackendController
    
  def index
# EVERYTHING AFTER HERE IS OLD STUFF
=begin
    # OPTIMIZE 0501 
    params[:sort] ||= 'name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    with = {:user_id => current_user.id} unless is_admin?
    
    @inventory_pools = InventoryPool.search params[:query], { :star => true, :page => params[:page], :per_page => 9999, #$per_page,
                                                              :order => params[:sort], :sort_mode => params[:sort_mode],
                                                              :with => with }
    if !is_admin? and @inventory_pools.total_entries == 1
      redirect_to backend_inventory_pool_path(@inventory_pools.first)
    else
      respond_to do |format|
        format.html
        format.js { search_result_rjs(@inventory_pools) }
      end
    end
=end
  end

  def show(date = params[:date])
    @date = date ? Date.parse(date) : Date.today
    redirect_to backend_inventory_pool_path(current_inventory_pool) if @date < Date.today
    
    orders = current_inventory_pool.orders.submitted
    
    today_and_next_4_days = [@date] 
    4.times { today_and_next_4_days << current_inventory_pool.next_open_date(today_and_next_4_days[-1] + 1.day) }
    
    visits = current_inventory_pool.visits.where("date <= ?", today_and_next_4_days.last)
    hand_overs, take_backs = visits.partition {|v| v.action == "hand_over" }
    
    @chart_data = today_and_next_4_days.map do |day|
      day_name = (day == Date.today) ? _("Today") : l(day, :format => "%a %d.%m")
      take_back_visits_on_day = take_backs.select{|v| v.date == day}
      take_back_workload = take_back_visits_on_day.size * 4 + take_back_visits_on_day.sum(&:quantity)
      hand_over_visits_on_day = hand_overs.select{|v| v.date == day }
      hand_over_workload = hand_over_visits_on_day.size * 4 + hand_over_visits_on_day.sum(&:quantity)
      [[take_back_workload, hand_over_workload],
        {:name => day_name,
         :value => "#{take_back_visits_on_day.size+hand_over_visits_on_day.size} Visits<br/>#{take_back_visits_on_day.sum(&:quantity)+hand_over_visits_on_day.sum(&:quantity)} Items"}]
    end
    
    hand_overs.keep_if {|v| v.date == @date}
    take_backs.keep_if {|v| v.date == @date}

    @orders_json = orders.to_json(:with => {:grouped_lines => {}, :user => {}})
    @orders_size = orders.size
    @hand_overs_json = hand_overs.to_json
    @hand_overs_size = hand_overs.size
    @take_backs_json = take_backs.to_json
    @take_backs_size = take_backs.size
  end
  
  def new
    @inventory_pool = InventoryPool.new
    render :action => 'edit'
  end

  def create
    @inventory_pool = InventoryPool.new
    update
    current_user.access_rights.create(:role => Role.where(:name => 'manager').first,
                                      :inventory_pool => @inventory_pool,
                                      :access_level => 3) unless @inventory_pool.new_record?
  end

  # TODO: this mess needs to be untangled and split up into functions called by new/create/update
  def update
    @inventory_pool ||= @inventory_pool = InventoryPool.find(params[:id]) 
    params[:inventory_pool][:print_contracts] ||= "false" # unchecked checkboxes are *not* being sent
    params[:inventory_pool][:email] = nil if params[:inventory_pool][:email].blank?
    if @inventory_pool.update_attributes(params[:inventory_pool])
      redirect_to backend_inventory_pool_path(@inventory_pool)
    else
      flash[:error] = @inventory_pool.errors.full_messages
      # TODO: set @current_inventory_pool here? See Backend::BackendController#current_inventory_pool
      if action_name == "create"
        render :action => 'edit'
      else
        render :action => 'show' # TODO 24** redirect to the correct tabbed form
      end
    end
  end

  def destroy
    @inventory_pool = InventoryPool.find(params[:id]) 

    if @inventory_pool.items.empty?
      
      @inventory_pool.destroy
      respond_to do |format|
        format.html { redirect_to backend_inventory_pools_path }
        format.js {
          render :update do |page|
            page.visual_effect :fade, "inventory_pool_#{@inventory_pool.id}" 
          end
        }
      end
    else
      # TODO 0607 ajax delete
      @inventory_pool.errors.add(:base, _("The Inventory Pool must be empty"))
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end


end
