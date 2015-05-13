class Borrow::ReservationsController < Borrow::ApplicationController

  before_filter only: [:create, :change_time_range] do
    @start_date = params[:start_date].try{|x| Date.parse(x)} || Date.today
    @end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id])

    @target_contract = current_user.reservations_bundles.unsubmitted.find_or_initialize_by(inventory_pool_id: @inventory_pool.id)
    @errors = []
    @errors << _('Inventory pool is closed on start date') unless @inventory_pool.is_open_on?(@start_date)
    @errors << _('Inventory pool is closed on end date') unless @inventory_pool.is_open_on?(@end_date)
    @errors << _('No orders are possible on this start date') if @start_date < Date.today + @inventory_pool.workday.reservation_advance_days.days
    @errors << _('Booking is no longer possible on this start date') if @inventory_pool.workday.reached_max_visits.include? @start_date
    @errors << _('Booking is no longer possible on this end date') if @inventory_pool.workday.reached_max_visits.include? @end_date
  end

  def create(model = current_user.models.borrowable.find(params[:model_id]),
             quantity = 1)
    unless model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(@start_date, @end_date, current_user.group_ids) >= quantity
      @errors << _('Item is not available in that time range')
    end
    if @errors.empty? and (reservations = model.add_to_contract(@target_contract, current_user, quantity, @start_date, @end_date, session[:delegated_user_id])) and reservations.all?(&:valid?)
      render status: :ok, json: reservations.first
    else
      render status: :bad_request, json: @errors.uniq.join(', ')
    end
  end

  def destroy
    begin
      current_user.reservations.unsubmitted.find(params[:line_id]).destroy
    rescue
    ensure
      render status: :ok, json: {id: params[:line_id].to_i}
    end
  end

  def change_time_range
    reservations = @target_contract.reservations.find(params[:line_ids])
    if @errors.empty?
      begin
        reservations.each{|line| line.update_time_line(@start_date, @end_date, current_user); line.reload }
        render status: :ok, json: reservations
      rescue => e
        render status: :bad_request, text: e
      end
    else
      render status: :bad_request, json: @errors.uniq.join(', ')
    end
  end

end
