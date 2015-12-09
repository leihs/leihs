class Manage::InventoryPoolsController < Manage::ApplicationController

  private

  # NOTE overriding super controller
  def required_manager_role
    if [:daily].include?(action_name.to_sym)
      require_role :group_manager, current_inventory_pool
    elsif [:edit].include?(action_name.to_sym)
      unless current_user.has_role?(:inventory_manager, current_inventory_pool)
        redirect_to manage_inventory_pool_users_path(current_inventory_pool)
      end
    else
      super
    end
  end

  public

  def daily(date = params[:date])
    if group_manager? and not lending_manager?
      redirect_to \
        manage_contracts_path(current_inventory_pool,
                              status: [:approved, :submitted, :rejected]),
        flash: params[:flash] and return
    end

    @date = date ? Date.parse(date) : Time.zone.today
    if @date == Time.zone.today
      # NOTE count returns a Hash because the group() in default scope
      @submitted_reservations_count = \
        current_inventory_pool.reservations_bundles.submitted.to_a.size
      @overdue_hand_overs_count = \
        current_inventory_pool.visits.hand_over.where('date < ?', @date).count
      @overdue_take_backs_count = \
        current_inventory_pool.visits.take_back.where('date < ?', @date).count
    else
      if params[:tab] == 'orders' or params[:tab] == 'last_visitors'
        params[:tab] = nil
      end
    end
    @hand_overs_count = \
      current_inventory_pool.visits.hand_over.where(date: @date).count
    @take_backs_count = \
      current_inventory_pool.visits.take_back.where(date: @date).count
    if session[:last_visitors]
      @last_visitors = session[:last_visitors].reverse.map
    end
  end

  def edit
    @inventory_pool = current_inventory_pool
    @holidays = \
      @inventory_pool
        .holidays
        .reject { |h| h.end_date < Time.zone.today }
        .sort_by(&:start_date)
  end

  # TODO: this mess needs to be untangled and split up
  # into functions called by new/create/update
  def update
    @inventory_pool = current_inventory_pool
    process_params params[:inventory_pool]
    @holidays_initial = @inventory_pool.holidays.reject do |h|
      h.end_date < Time.zone.today
    end.sort_by(&:start_date)

    if @inventory_pool.update_attributes(params[:inventory_pool])
      flash[:notice] = _('Inventory pool successfully updated')
      redirect_to manage_edit_inventory_pool_path(@inventory_pool)
    else
      setup_holidays_for_render params[:inventory_pool][:holidays_attributes]
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq.join(', ')
      render :edit
    end
  end

  def workload(date = params[:date].try { |x| Date.parse(x) })
    today_and_next_4_days = [date]
    4.times do
      today_and_next_4_days << \
        current_inventory_pool.next_open_date(today_and_next_4_days[-1] + 1.day)
    end

    grouped_visits = \
      current_inventory_pool
        .visits
        .includes(:user)
        .where('date <= ?', today_and_next_4_days.last)
        .group_by { |x| [x.action, x.date] }

    chart_data = today_and_next_4_days.map do |day|
      day_name = (day == Time.zone.today) ? _('Today') : l(day, format: '%a %d.%m')
      take_back_visits_on_day = grouped_visits[[:take_back, day]] || []
      take_back_workload = \
        take_back_visits_on_day.size * 4 + take_back_visits_on_day.sum(&:quantity)
      hand_over_visits_on_day = grouped_visits[[:hand_over, day]] || []
      hand_over_workload = \
        hand_over_visits_on_day.size * 4 + hand_over_visits_on_day.sum(&:quantity)
      [[take_back_workload, hand_over_workload],
       { name: day_name,
         value: \
         "<div class='row text-ellipsis' title='#{_('Visits')}'>" \
           "#{take_back_visits_on_day.size + \
              hand_over_visits_on_day.size} #{_('Visits')}" \
         '</div>' \
         "<div class='row text-ellipsis' title='#{_('Items')}'>" \
           "#{take_back_visits_on_day.sum(&:quantity) + \
              hand_over_visits_on_day.sum(&:quantity)} #{_('Items')}" \
         '</div>' }]
    end

    respond_to do |format|
      format.json { render json: { data: chart_data } }
    end
  end

  def latest_reminder
    user = current_inventory_pool.users.find(params[:user_id])
    visit = current_inventory_pool.visits.find(params[:visit_id])
    @notifications = \
      user.notifications.where('created_at >= ?', visit.date).limit(10)
  end

  private

  def process_params(ip)
    ip[:email] = nil if params[:inventory_pool][:email].blank?
    ip[:workday_attributes][:workdays].delete '' if ip[:workday_attributes]
  end

  def setup_holidays_for_render(holidays_attributes)
    if holidays_attributes
      params_holidays = holidays_attributes.values
      @holidays = \
        @holidays_initial \
        + params_holidays.reject { |h| h[:id] }.map { |h| Holiday.new h }
      @holidays.select(&:id).each do |holiday|
        if added_holiday = params_holidays.detect { |h| h[:id].to_i == holiday.id }
          holiday._destroy = 1 if added_holiday.key? '_destroy'
        end
      end
    else
      @holidays = []
    end
  end

end
