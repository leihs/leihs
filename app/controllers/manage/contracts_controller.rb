class Manage::ContractsController < Manage::ApplicationController
  
  before_filter :except => [:approve, :reject] do
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  before_filter :only => [:approve, :reject] do
    @contract = current_inventory_pool.contracts.submitted.find(params[:id])
  end

  private

  # NOTE overriding super controller
  def required_manager_role
    closed_actions = [:sign]
    if closed_actions.include?(action_name.to_sym)
      super
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

######################################################################

  def index
    respond_to do |format|
      format.html
      format.json {
        @contracts = ContractLinesBundle.filter params, nil, current_inventory_pool
        set_pagination_header @contracts
      }
    end
  end

  def edit
    @contract = current_inventory_pool.contracts.find(params[:id])
    @user = @contract.user
    @group_ids = @user.group_ids
    add_visitor(@user)
    @contract_lines = @contract.lines
    @models = @contract.models
    @purposes = @contract.lines.map(&:purpose).uniq
    @grouped_lines = @contract_lines.group_by{|g| [g.start_date, g.end_date]}
    @grouped_lines.each_pair do |k,lines|
      @grouped_lines[k] = lines.sort_by{|line| line.model.name}.group_by{|line| line.model}
    end
    @start_date = @contract.min_date
    @end_date = @contract.max_date
  end

  def show
    render "documents/contract", layout: "print"
  end

  def value_list
    render "documents/value_list", layout: "print"
  end

  def picking_list
    render "documents/picking_list", layout: "print"
  end

  def approve(force = (params.has_key? :force) ? true : false)
    if @contract.approve(params[:comment], true, current_user, force)
      respond_to do |format|
        format.json { render :json => true, :status => 200  }
      end
    else
      errors = @contract.errors.full_messages.uniq.join("\n")
      respond_to do |format|
        format.json { render :text => errors, :status => 500 }
      end
    end
  end

  def reject
    if request.post? and params[:comment] and @contract.reject(params[:comment], current_user)
      respond_to do |format|
        format.json { render :json => true, :status => 200 }
        format.html { redirect_to manage_daily_view_path, :flash => {:success => _("Order rejected")}}
      end
    else
      errors = @contract.errors.full_messages.uniq.join("\n")
      respond_to do |format|
        format.json { render :text => errors, :status => 500 }
        format.html { render :edit }
      end
    end
  end

  def sign(line_ids = params[:line_ids] || raise("line_ids is required"),
           purpose_description = params[:purpose],
           note = params[:note])
    
    lines = @contract.contract_lines.find(line_ids)
    if purpose_description
      purpose = Purpose.create :description => purpose_description
      lines.each do |line|
        if line.purpose.nil?
          line.purpose = purpose
          line.save
        end
      end
    end

    if (contract = @contract.sign(current_user, lines, note, params[:delegated_user_id])).valid?
      render json: @contract.user.contracts.signed.find(contract.id).to_json
    else 
      render :status => :bad_request, :text => @contract.errors.full_messages.uniq.join(", ")
    end
  end

  def swap_user
    contract = current_inventory_pool.contracts.find params[:id]
    user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
    delegated_user = ( params[:delegated_user_id] ? current_inventory_pool.users.find(params[:delegated_user_id]) : nil )
    lines = contract.contract_lines
    ActiveRecord::Base.transaction do
      lines.each do |line|
        line.update_attributes(user: user, delegated_user: delegated_user)
      end
    end
    if lines.all? &:valid?
      render json: user.contracts.find_by(status: contract.status, inventory_pool_id: current_inventory_pool).to_json
    else
      errors = lines.flat_map {|line| line.errors.full_messages }
      render :status => :bad_request, :text => errors.uniq.join(", ")
    end
  end

end
