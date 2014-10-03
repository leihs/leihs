class Manage::InventoryPoolsController < Manage::ApplicationController
  
  before_filter :only => [:index, :new, :create] do
    not_authorized!(redirect_path: root_path) and return unless is_admin?
  end

  private

  # NOTE overriding super controller
  def required_manager_role
    open_actions = [:daily]
    if not open_actions.include?(action_name.to_sym)
      require_role :lending_manager, current_inventory_pool
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

  def index
    @inventory_pools = InventoryPool.all.sort
  end

  def daily(date = params[:date])
    if is_group_manager? and not is_lending_manager?
      redirect_to manage_contracts_path(current_inventory_pool, status: [:approved, :submitted, :rejected]), flash: params[:flash] and return
    end

    @date = date ? Date.parse(date) : Date.today
    if @date == Date.today
      @submitted_contracts = current_inventory_pool.contracts.submitted.includes([:user, {:contract_lines => :model}]).order(Contract.arel_table[:created_at].desc).reverse
      @purposes = @submitted_contracts.map(&:purpose)
      @overdue_hand_overs_count = current_inventory_pool.visits.hand_over.where("date < ?", @date).count
      @overdue_take_backs_count = current_inventory_pool.visits.take_back.where("date < ?", @date).count
    else
      params[:tab] = nil if params[:tab] == "orders" or params[:tab] == "last_visitors"
    end
    @hand_overs_count = current_inventory_pool.visits.hand_over.where(:date => @date).count
    @take_backs_count = current_inventory_pool.visits.take_back.where(:date => @date).count
    @last_visitors = session[:last_visitors].reverse.map if session[:last_visitors]
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
      redirect_to manage_inventory_pools_path
    else
      setup_holidays_for_render params[:inventory_pool][:holidays_attributes]
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq.join(", ")
      render :new
    end

    current_user.access_rights.create(:role => :inventory_manager, :inventory_pool => @inventory_pool) unless @inventory_pool.new_record?
  end

  # TODO: this mess needs to be untangled and split up into functions called by new/create/update
  def update
    @inventory_pool ||= InventoryPool.find(params[:id])
    process_params params[:inventory_pool]
    @holidays_initial = @inventory_pool.holidays.reject{|h| h.end_date < Date.today}.sort_by(&:start_date)

    if @inventory_pool.update_attributes(params[:inventory_pool])
      flash[:notice] = _("Inventory pool successfully updated")
      redirect_to manage_edit_inventory_pool_path(@inventory_pool)
    else
      setup_holidays_for_render params[:inventory_pool][:holidays_attributes]
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq.join(", ")
      render :edit
    end
  end

  # delete is idempotent
  def destroy
    begin
      InventoryPool.find_by_id(params[:id]).try :destroy
      respond_to do |format|
        format.json { render :status => :no_content, :nothing => true }
        format.html { redirect_to action: :index, flash: { success: _("%s successfully deleted") % _("Inventory Pool") }}
      end
    rescue => e
      respond_to do |format|
        format.json { render :status => :bad_request, :nothing => true }
        format.html { redirect_to action: :index, flash: { error: e }}
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
         :value => "<div class='row text-ellipsis' title='#{_("Visits")}'>#{take_back_visits_on_day.size+hand_over_visits_on_day.size} #{_("Visits")}</div><div class='row text-ellipsis' title='#{_("Items")}'>#{take_back_visits_on_day.sum(&:quantity)+hand_over_visits_on_day.sum(&:quantity)} #{_("Items")}</div>"}]
    end

    respond_to do |format|
      format.json { render :json => {data: chart_data} }
    end
  end

  def process_params ip
    ip[:email] = nil if params[:inventory_pool][:email].blank?
    ip[:workday_attributes][:workdays].delete "" if ip[:workday_attributes]
  end

  def setup_holidays_for_render holidays_attributes
    if holidays_attributes
      params_holidays = holidays_attributes.values
      @holidays = @holidays_initial + params_holidays.reject{|h| h[:id]}.map{|h| Holiday.new h}
      @holidays.select(&:id).each do |holiday|
        if added_holiday = params_holidays.detect{|h| h[:id].to_i == holiday.id}
          holiday._destroy = 1 if added_holiday.has_key? "_destroy"
        end
      end
    else
      @holidays = []
    end
  end

  def latest_reminder
    user = current_inventory_pool.users.find(params[:user_id])
    visit = current_inventory_pool.visits.find(params[:visit_id])
    latest_remind = user.reminders.last
    if latest_remind and latest_remind.created_at > visit.date
      @reminder = latest_remind 
    else
      render :nothing => true, :status => :not_found
    end
  end

end
