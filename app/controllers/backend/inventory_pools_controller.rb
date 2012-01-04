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
        
    today_and_next_4_days = [@date] 
    4.times { today_and_next_4_days << current_inventory_pool.next_open_date(today_and_next_4_days[-1] + 1.day) }
    
    grouped_visits = current_inventory_pool.visits.where("date <= ?", today_and_next_4_days.last).group_by {|x| [x.action, x.date] }
    
    @chart_data = today_and_next_4_days.map do |day|
      day_name = (day == Date.today) ? _("Today") : l(day, :format => "%a %d.%m")
      take_back_visits_on_day = grouped_visits[["take_back", day]] || []
      take_back_workload = take_back_visits_on_day.size * 4 + take_back_visits_on_day.sum(&:quantity)
      hand_over_visits_on_day = grouped_visits[["hand_over", day]] || []
      hand_over_workload = hand_over_visits_on_day.size * 4 + hand_over_visits_on_day.sum(&:quantity)
      [[take_back_workload, hand_over_workload],
        {:name => day_name,
         :value => "#{take_back_visits_on_day.size+hand_over_visits_on_day.size} Visits<br/>#{take_back_visits_on_day.sum(&:quantity)+hand_over_visits_on_day.sum(&:quantity)} Items"}]
    end

    orders = current_inventory_pool.orders.submitted
    @orders_json = orders.to_json(:with => {:lines => {:include => :model}, 
                                            :user => {:methods => [:image_url]}},
                                  :methods => :quantity)
    @orders_size = orders.size
    
    #TODO Include overdue hand overs but only if date == today (Franco: ???)
    ho = grouped_visits.select {|k, v| k[0] == "hand_over" and k[1] <= @date }.values.flatten
    @hand_overs_json = ho.to_json(:with => {:lines => {},
                                            :user => {:methods => [:image_url]}},
                                  :methods => :is_overdue)
    @hand_overs_size = ho.size
    
    #TODO Include overdue take backs but only if date == today (Franco: ???)
    tb = grouped_visits.select {|k, v| k[0] == "take_back" and k[1] <= @date }.values.flatten
    @take_backs_json = tb.to_json(:with => {:lines => {},
                                            :user => {:methods => [:image_url]}},
                                  :methods => :is_overdue)
    @take_backs_size = tb.size
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
