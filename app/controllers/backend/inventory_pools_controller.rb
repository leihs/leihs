class Backend::InventoryPoolsController < Backend::BackendController
  
  before_filter :only => [:index, :new, :create] do
    not_authorized!(redirect_path: root_path) and return unless is_admin?
  end

  def index
    @inventory_pools = InventoryPool.all
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
    @inventory_pool.workday = Workday.new
  end

  def edit
    @inventory_pool = InventoryPool.find params[:id]
    @holidays = @inventory_pool.holidays.reject{|h| h.end_date < Date.today}.sort_by(&:start_date)
  end

  def create
    @inventory_pool = InventoryPool.new
    process_params params[:inventory_pool]

    if @inventory_pool.update_attributes(params[:inventory_pool]) and @inventory_pool.workday.save
      flash[:notice] = _("Inventory pool successfully created")
      redirect_to backend_inventory_pools_path
    else
      setup_holidays_for_render params[:inventory_pool][:holidays_attributes]
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq
      render :edit
    end

    current_user.access_rights.create(:role => Role.where(:name => 'manager').first,
                                      :inventory_pool => @inventory_pool,
                                      :access_level => 3) unless @inventory_pool.new_record?
  end

  # TODO: this mess needs to be untangled and split up into functions called by new/create/update
  def update
    @inventory_pool ||= InventoryPool.find(params[:id])
    process_params params[:inventory_pool]

    if @inventory_pool.update_attributes(params[:inventory_pool])
      flash[:notice] = _("Inventory pool successfully updated")
      redirect_to edit_backend_inventory_pool_path(@inventory_pool)
    else
      setup_holidays_for_render params[:inventory_pool][:holidays_attributes]
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq
      render :edit
    end
  end

  def destroy
    @inventory_pool ||= InventoryPool.find(params[:id])

    respond_to do |format|
      format.json do
        begin @inventory_pool.destroy
          render :json => true, status: :ok
        rescue ActiveRecord::DeleteRestrictionError => e
          @inventory_pool.errors.add(:base, e)
          render :text => @inventory_pool.errors.full_messages.uniq.join(", "), :status => :forbidden
        end
      end
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

  def process_params ip
    ip[:print_contracts] ||= "false" # unchecked checkboxes are *not* being sent
    ip[:email] = nil if params[:inventory_pool][:email].blank?
    ip[:workday_attributes][:workdays].delete "" if ip[:workday_attributes]
  end

  def setup_holidays_for_render holidays_attributes
    if holidays_attributes
      params_holidays = holidays_attributes.values
      @holidays = @inventory_pool.holidays.reload + params_holidays.reject{|h| h[:id]}.map{|h| Holiday.new h}
      @holidays.select(&:id).each do |holiday|
        holiday._destroy = 1 if params_holidays.detect{|h| h[:id].to_i == holiday.id}.has_key? "_destroy"
      end
    else @holidays = [] end
  end
end
