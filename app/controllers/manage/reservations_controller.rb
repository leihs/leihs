class Manage::ReservationsController < Manage::ApplicationController

  private

  # NOTE overriding super controller
  def required_manager_role
    closed_actions = [:assign, :assign_or_create, :remove_assignment, :take_back]
    if closed_actions.include?(action_name.to_sym)
      super
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

  def index
    @reservations = Reservation.filter params, current_inventory_pool
  end

  def update
    # TODO: params.require(:reservation).permit(:item_id, :model_id, :option_id,
    # :purpose_id, :quantity, :start_date, :end_date)
    params[:reservation].delete(:contract_id)

    @reservation = current_inventory_pool.reservations.find(params[:line_id])
    unless @reservation.update_attributes(params[:reservation])
      render status: :bad_request,
             text: @reservation.errors.full_messages.uniq.join(', ')
    end
  end

  before_action only: [:create, :create_for_template, :assign_or_create] do
    @status, user_id = params[:contract_id].split('_')[0, 2]
    @user = current_inventory_pool.users.find(user_id)
  end

  def create
    begin
      record = if params[:model_id]
                 current_inventory_pool.models.find(params[:model_id])
               else
                 current_inventory_pool.options.find(params[:option_id])
               end
      @reservation = create_reservation(@user,
                                        current_inventory_pool,
                                        @status,
                                        record,
                                        1,
                                        params[:start_date],
                                        params[:end_date],
                                        params[:purpose_id])
    rescue => e
      render status: :bad_request, text: e
    end
  end

  def create_for_template
    @reservations = []
    ActiveRecord::Base.transaction do
      template = Template.find(params[:template_id])
      template.model_links.each do |link|
        next unless current_inventory_pool.models.exists?(id: link.model_id)
        link.quantity.times do
          @reservations.push \
            create_reservation(@user,
                               current_inventory_pool,
                               @status,
                               current_inventory_pool.models.find(link.model_id),
                               1,
                               params[:start_date],
                               params[:end_date],
                               params[:purpose_id])
        end
      end
    end
  end

  def destroy
    begin
      current_inventory_pool
        .reservations
        .where(id: (params[:line_id] || params[:line_ids]))
        .destroy_all
    rescue => e
      Rails.logger.error e
    ensure
      render status: :ok, json: { id: params[:line_id].to_i }
    end
  end

  def change_time_range(
    reservations = current_inventory_pool.reservations.find(params[:line_ids]),
    start_date = params[:start_date].try { |x| Date.parse(x) },
    end_date = params[:end_date].try { |x| Date.parse(x) } || Date.tomorrow)
    begin
      reservations.each do |line|
        line.update_time_line \
          (start_date || line.start_date),
          end_date,
          current_user
      end
      render status: :ok, json: reservations
    rescue => e
      render status: :bad_request, text: e
    end
  end

  def assign
    item = \
      current_inventory_pool.items.find_by_inventory_code params[:inventory_code]
    line = current_inventory_pool.reservations.approved.find params[:id]

    if item and line and line.model_id == item.model_id
      unless line.update_attributes(item: item)
        @error = { message: line.errors.full_messages.uniq.join(', ') }
      end
    else
      unless params[:inventory_code].blank?
        @error =
          if item and line and line.model_id != item.model_id
            { message: \
                _('The inventory code %s is not valid for this model') % \
                params[:inventory_code] }
          elsif line
            { message: \
                _("The item with the inventory code '%s' was not found") % \
                params[:inventory_code] }
          elsif item
            { message: _('The line was not found') }
          else
            { message: _('Assigning the inventory code fails') }
          end
      end
      line.update_attributes(item: nil)
    end

    if @error.blank?
      render status: :ok, json: line
    else
      render status: :bad_request, json: @error
    end
  end

  def assign_or_create
    contract = \
      current_inventory_pool
        .reservations_bundles
        .find_by(id: params[:contract_id])
    contract ||= \
      @user
        .reservations_bundles
        .new(inventory_pool: current_inventory_pool, status: @status)

    item = current_inventory_pool.items.where(inventory_code: code_param).first
    model = find_model(item)
    option = find_option unless model

    line, error = create_new_line_or_assign(model,
                                            item,
                                            option,
                                            contract)

    if error.blank?
      render status: :ok, json: line
    else
      render status: :bad_request, text: error
    end
  end

  def remove_assignment
    line = current_inventory_pool.reservations.approved.find params[:id]
    line.update_attributes(item_id: nil)
    head status: :ok
  end

  def take_back
    returned_quantity = params[:returned_quantity]
    reservations = current_inventory_pool.reservations.find(params[:ids])

    returned_quantity.each_pair do |k, v|
      line = reservations.detect { |l| l.id == k.to_i }
      next unless line and v.to_i < line.quantity
      new_line = line.dup # NOTE use .dup instead of .clone (from Rails 3.1)
      new_line.quantity -= v.to_i
      new_line.save
      line.update_attributes(quantity: v.to_i)
    end if returned_quantity

    reservations.each do |l|
      l.update_attributes(returned_date: Time.zone.today,
                          returned_to_user_id: current_user.id)
    end

    head status: :ok
  end

  def swap_user
    user = current_inventory_pool.users.find params[:user_id]
    reservations = current_inventory_pool.reservations.where(id: params[:line_ids])
    ActiveRecord::Base.transaction do
      reservations.each do |line|
        delegated_user = if user.delegation?
                           if user.delegated_users.include? line.delegated_user
                             line.delegated_user
                           else
                             user.delegator_user
                           end
                         end
        line.update_attributes(user: user, delegated_user: delegated_user)
      end
    end
    if reservations.all?(&:valid?)
      head status: :ok
    else
      render status: :bad_request, nothing: true
    end
  end

  def swap_model
    reservations = current_inventory_pool.reservations.where(id: params[:line_ids])
    model = Model.find(params[:model_id])
    ActiveRecord::Base.transaction do
      reservations.each do |line|
        line.update_attributes(model: model, item_id: nil)
      end
    end
    if reservations.all?(&:valid?)
      render json: reservations
    else
      render status: :bad_request, nothing: true
    end
  end

  def print
    @reservations = current_inventory_pool.reservations.where(id: params[:ids])
    case params[:type]
    when 'value_list'
        @user = @reservations.first.user
        render 'documents/reservations', layout: 'print'
    when 'picking_list'
        @contract = @reservations.first.contract
        render 'documents/picking_list', layout: 'print'
    end
  end

  private

  def code_param
    params[:code]
  end

  def model_group_id_param
    params[:model_group_id]
  end

  def model_id_param
    params[:model_id]
  end

  def option_id_param
    params[:model_id]
  end

  def quantity_param
    (params[:quantity] || 1).to_i
  end

  def start_date_param
    params[:start_date].try { |x| Date.parse(x) } || Time.zone.today
  end

  def end_date_param
    params[:end_date].try { |x| Date.parse(x) } || Date.tomorrow
  end

  def line_ids_param
    params[:line_ids]
  end

  def find_model(item)
    if not code_param.blank?
      item.model if item
    elsif model_group_id_param
      # TODO: scope current_inventory_pool ?_param
      Template.find(model_group_id_param)
    elsif model_id_param
      current_inventory_pool.models.find(model_id_param)
    end
  end

  def find_option
    if option_id_param
      option = current_inventory_pool.options.find(option_id_param)
    end
    option || \
      current_inventory_pool
        .options
        .where(inventory_code: code_param)
        .first
  end

  # TODO: merge to ReservationsBundle#add_lines
  def create_reservation(user,
                         inventory_pool,
                         status,
                         record,
                         quantity,
                         start_date,
                         end_date,
                         purpose_id)
    if record.is_a? Model
      reservation = user.item_lines.new(model: record)
    elsif record.is_a? Option
      reservation = user.option_lines.new(option: record)
    end
    reservation.inventory_pool = inventory_pool
    reservation.status = status
    reservation.quantity = quantity.to_i
    reservation.start_date = \
      start_date.try { |x| Date.parse(x) } || Time.zone.today
    reservation.end_date = end_date.try { |x| Date.parse(x) } || Date.tomorrow
    reservation.purpose = Purpose.where(id: purpose_id).first

    # NOTE we need to store because the availability reads the persisted
    # reservations (as running_reservations)
    # then we rollback on failing conditions
    Reservation.transaction do
      reservation.save!
      if (group_manager? and not lending_manager?) and not reservation.available?
        raise _('Not available')
      else
        reservation
      end
    end
  end

  def create_new_line_or_assign(model,
                                item,
                                option,
                                contract)
    error = nil
    line = nil
    # create new line or assign
    if model
      # try to assign for (selected)line_ids first
      if line_ids_param and code_param
        line = contract.reservations.where(id: line_ids_param,
                                           model_id: item.model.id,
                                           item_id: nil).first
      end
      # try to assign to contract reservations of the customer
      if code_param
        line ||= \
          contract
            .reservations
            .where(model_id: model.id, item_id: nil)
            .order(:start_date)
            .first
      end
      # add new line
      line ||= model.add_to_contract(contract,
                                     contract.user,
                                     quantity_param,
                                     start_date_param,
                                     end_date_param).first
      if model_group_id_param.nil? \
        and item \
        and line \
        and not line.update_attributes(item: item)
        error = line.errors.values.join
      end
    elsif option
      if line = contract.reservations.where(option_id: option.id,
                                            start_date: start_date_param,
                                            end_date: end_date_param).first
        line.quantity += quantity_param
        line.save
      # FIXME: go through contract.add_lines ??
      elsif not line = contract.user.option_lines.create(
        status: contract.status,
        inventory_pool: contract.inventory_pool,
        option: option,
        quantity: quantity_param,
        start_date: start_date_param,
        end_date: end_date_param)
        error = _('The option could not be added')
      end
    else
      error =
        if code
          _('A model for the Inventory Code / ' \
            "Serial Number '%s' was not found") % \
           code_param
        elsif model_id_param
          _("A model with the ID '%s' was not found") % \
            model_id_param
        elsif model_group_id_param
          _("A template with the ID '%s' was not found") % \
            model_group_id_param
        end
    end
    [line, error]
  end
end
