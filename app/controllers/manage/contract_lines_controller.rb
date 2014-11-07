class Manage::ContractLinesController < Manage::ApplicationController

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
    @contract_lines = ContractLine.filter params, current_inventory_pool
  end

  def update
    @contract_line = current_inventory_pool.contract_lines.find(params[:line_id])
    unless @contract_line.update_attributes(params[:contract_line])
      render :status => :bad_request, :text => @contract_line.errors.full_messages.uniq.join(', ')
    end
  end

  def create
    begin
      contract_id = params[:contract_id] || current_inventory_pool.users.find(params[:user_id]).get_approved_contract(current_inventory_pool).id
      record = if params[:model_id]
                 current_inventory_pool.models.find(params[:model_id])
               else
                 current_inventory_pool.options.find(params[:option_id])
               end
      @contract_line = create_contract_line contract_id, record, 1, params[:start_date], params[:end_date], params[:purpose_id]
    rescue => e
      render :status => :bad_request, :text => e
    end
  end

  def create_for_template
    @contract_lines = []
    ActiveRecord::Base.transaction do
      template = Template.find(params[:template_id])
      template.model_links.each do |link|
        if current_inventory_pool.models.exists?(:id => link.model_id)
          link.quantity.times do
            @contract_lines.push create_contract_line params[:contract_id], current_inventory_pool.models.find(link.model_id), 1, params[:start_date], params[:end_date], params[:purpose_id]
          end
        end
      end
    end
  end

  def destroy
    begin
      current_inventory_pool.contract_lines.where(:id => (params[:line_id] || params[:line_ids])).destroy_all
    rescue => e
      Rails.logger.error e
    ensure
      render :status => :ok, :json => {id: params[:line_id].to_i}
    end
  end

  def change_time_range(lines = current_inventory_pool.contract_lines.find(params[:line_ids]),
                        start_date = params[:start_date].try{|x| Date.parse(x)},
                        end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow)
    begin
      lines.each{|line| line.contract.update_time_line(line.id, (start_date||line.start_date), end_date, current_user)}
      render :status => :ok, :json => lines
    rescue => e
      render :status => :bad_request, :text => e
    end
  end

  def assign
    item = current_inventory_pool.items.find_by_inventory_code params[:inventory_code]
    line = current_inventory_pool.contract_lines.to_hand_over.find params[:id]

    if item and line and line.model_id == item.model_id
      @error = {:message => line.errors.full_messages.uniq.join(', ')} unless line.update_attributes(item: item)
    else
      unless params[:inventory_code].blank?
        @error = if item and line and line.model_id != item.model_id
          {:message => _("The inventory code %s is not valid for this model" % params[:inventory_code])}
        elsif line
          {:message => _("The item with the inventory code '%s' was not found" % params[:inventory_code])}
        elsif item
          {:message => _("The line was not found")}
        else 
          {:message => _("Assigning the inventory code fails")}
        end
      end
      line.update_attributes(item: nil)
    end
    
    if @error.blank? 
      render :status => :ok, :json => line
    else
      render :status => :bad_request, :json => @error
    end
  end

  def assign_or_create( quantity = (params[:quantity] || 1).to_i,
                        start_date = params[:start_date].try{|x| Date.parse(x)} || Date.today,
                        end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow,
                        model_id = params[:model_id],
                        model_group_id = params[:model_group_id],
                        option_id = params[:option_id],
                        code = params[:code],
                        line_ids = params[:line_ids])

    contract = current_inventory_pool.contracts.find(params[:contract_id])
    
    # find model or option 
    model = if not code.blank?
      item = current_inventory_pool.items.where(:inventory_code => code).first 
      item.model if item
    elsif model_group_id
      Template.find(model_group_id) # TODO scope current_inventory_pool ?
    elsif model_id
      current_inventory_pool.models.find(model_id)
    end
    unless model
      option = current_inventory_pool.options.find option_id if option_id
      option ||= current_inventory_pool.options.where(:inventory_code => code).first
    end
    
    # create new line or assign
    if model
      # try to assign for (selected)line_ids first
      line = contract.lines.where(:id => line_ids, :model_id => item.model, :item_id => nil).first if line_ids and code
      # try to assign to contract lines of the customer
      line ||= contract.lines.where(:model_id => model.id, :item_id => nil).order(:start_date).first if code
      # add new line
      line ||= model.add_to_contract(contract, contract.user, quantity, start_date, end_date).first
      @error = line.errors.values.join if model_group_id.nil? and item and line and not line.update_attributes(item: item)
    elsif option
      if line = contract.lines.where(:option_id => option.id, :start_date => start_date, :end_date => end_date).first
        line.quantity += quantity
        line.save
      # FIXME go through contract.add_lines ??
      elsif not line = contract.option_lines.create(:option => option, :quantity => quantity, :start_date => start_date, :end_date => end_date)
        @error = _("The option could not be added" % code)
      end
    else
      @error = if code
        _("A model for the Inventory Code / Serial Number '%s' was not found" % code)
      elsif model_id
        _("A model with the ID '%s' was not found" % model_id)
      elsif model_group_id
        _("A template with the ID '%s' was not found" % model_group_id)
      end
    end
    
    if @error.blank?
      render :status => :ok, :json => line
    else
      render :status => :bad_request, :text => @error
    end
  end

  def remove_assignment
    line = current_inventory_pool.contract_lines.to_hand_over.find params[:id]
    line.update_attributes({:item_id => nil})
    render :nothing=> true, :status => :no_content
  end

  def take_back
    returned_quantity = params[:returned_quantity]      
    lines = current_inventory_pool.contract_lines.find(params[:ids])

    lines.each do |l|
      l.update_attributes(:returned_date => Date.today, :returned_to_user_id => current_user.id)
      l.item.histories.create(:user => current_user, :text => _("Item taken back"), :type_const => History::ACTION) unless l.item.is_a? Option
    end

    if returned_quantity
      returned_quantity.each_pair do |k,v|
        line = lines.detect {|l| l.id == k.to_i }
        if line and v.to_i < line.quantity
          # NOTE: line is an OptionLine, since the ItemLine's quantity is always 1
          new_line = line.dup # NOTE use .dup instead of .clone (from Rails 3.1)
          new_line.quantity -= v.to_i
          new_line.returned_date = nil
          new_line.save
          line.update_attributes(:quantity => v.to_i)
        end
      end
    end

    # fetch all envolved contracts    
    contracts = lines.collect(&:contract).uniq 

    # close the envolved contracts where all lines are finally returned
    contracts.each do |c|
      c.close if c.lines.all? { |l| !l.returned_date.nil? }
    end

    render :status => :no_content, :nothing => true
  end

  def swap_user
    user = current_inventory_pool.users.find params[:user_id]
    lines = current_inventory_pool.contract_lines.where(:id => params[:line_ids])
    contract = user.get_approved_contract(current_inventory_pool)
    ActiveRecord::Base.transaction do
      lines.each do |line|
        line.update_attributes(:contract_id => contract.id)
      end
    end
    render status: :no_content, :nothing => true
  end

  def print
    @contract_lines = current_inventory_pool.contract_lines.where(id: params[:ids])
    case params[:type]
      when "value_list"
        @user = @contract_lines.first.user
        render "documents/contract_lines", layout: "print"
      when "picking_list"
        @contract = @contract_lines.first.contract
        render "documents/picking_list", layout: "print"
    end
  end

  private

  def create_contract_line contract_id, record, quantity, start_date, end_date, purpose_id
    if record.is_a? Model
      contract_line = ItemLine.new
      contract_line.model = record
    elsif record.is_a? Option
      contract_line = OptionLine.new
      contract_line.option = record
    end
    contract_line.contract = current_inventory_pool.contracts.find contract_id
    contract_line.quantity = quantity.to_i
    contract_line.start_date = start_date.try{|x| Date.parse(x)} || Date.today
    contract_line.end_date = end_date.try{|x| Date.parse(x)} || Date.tomorrow
    contract_line.purpose = Purpose.where(id: purpose_id).first

    # NOTE we need to store because the availability reads the persisted contract_lines (as running_lines)
    # then we rollback on failing conditions
    ContractLine.transaction do
      contract_line.save!
      if (is_group_manager? and not is_lending_manager?) and not contract_line.available?
        raise _("Not available")
      else
        contract_line
      end
    end
  end

end
