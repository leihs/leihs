class Borrow::ContractLinesController < Borrow::ApplicationController

  before_filter only: [:create, :change_time_range] do
    @start_date = params[:start_date].try{|x| Date.parse(x)} || Date.today
    @end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id])

    @target_contract = current_user.get_unsubmitted_contract(@inventory_pool, get_current_delegated_user)
    @target_contract.errors.add(:base, _("Inventory pool is closed on start date")) unless @inventory_pool.is_open_on?(@start_date)
    @target_contract.errors.add(:base, _("Inventory pool is closed on end date")) unless @inventory_pool.is_open_on?(@end_date)
    @target_contract.errors.add(:base, _("No orders are possible on this start date")) if @start_date < Date.today + @inventory_pool.workday.reservation_advance_days.days
    @target_contract.errors.add(:base, _("Booking is no longer possible on this start date")) if @inventory_pool.workday.reached_max_visits.include? @start_date
    @target_contract.errors.add(:base, _("Booking is no longer possible on this end date")) if @inventory_pool.workday.reached_max_visits.include? @end_date
  end

  def create(model = current_user.models.borrowable.find(params[:model_id]),
             quantity = 1)
    unless model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(@start_date, @end_date, current_user.group_ids) >= quantity
      @target_contract.errors.add(:base, _("Item is not available in that time range"))
    end

    if not @target_contract.errors.any? and (lines = model.add_to_contract(@target_contract, current_user.id, quantity, @start_date, @end_date)) and @target_contract.save
      render :status => :ok, :json => lines.first
    else
      render :status => :bad_request, :json => @target_contract.errors.full_messages.uniq.join(", ")
    end
  end

  def destroy
    begin
      unsubmitted_contracts.flat_map(&:lines).detect {|line| line.id  == params[:line_id].to_i }.destroy
    rescue
    ensure
      render :status => :ok, :json => {id: params[:line_id].to_i}
    end
  end

  def change_time_range
    lines = @target_contract.lines.find(params[:line_ids])
    quantity = lines.sum(&:quantity)

    if not @target_contract.errors.any? and
       lines.each{|line| @target_contract.update_time_line(line.id, @start_date, @end_date, current_user); line.reload } and
       @target_contract.save
      render :status => :ok, :json => lines
    else
      render :status => :bad_request, :json => @target_contract.errors.full_messages.uniq.join(", ")
    end
  end

end
