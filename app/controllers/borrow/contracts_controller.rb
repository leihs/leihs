class Borrow::ContractsController < Borrow::ApplicationController

  before_filter :only => [:current, :timed_out] do
    @grouped_and_merged_lines = Contract.grouped_and_merged_lines(current_user.contract_lines.unsubmitted)
    @models = current_user.contract_lines.unsubmitted.map(&:model).uniq
    @inventory_pools = current_user.contract_lines.unsubmitted.map(&:inventory_pool).uniq
  end

  def index
    respond_to do |format|
      format.json { @contracts = ContractLinesBundle.filter params, current_user }
      format.html { @grouped_and_merged_lines = Contract.grouped_and_merged_lines current_user.contract_lines.submitted }
    end
  end

  def current
  end

  def submit
    Contract.transaction do
      current_user.contract_lines.unsubmitted.each do |c|
        c.created_at = DateTime.now
        c.delegated_user = c.user.delegated_users.find(session[:delegated_user_id]) if c.user.is_delegation
      end
      if current_user.contracts.unsubmitted.all? {|c| c.submit(params[:purpose])}
        flash[:notice] = _("Your order has been successfully submitted, but is NOT YET APPROVED.")
        redirect_to borrow_root_path
      else
        flash[:error] = current_user.contract_lines.unsubmitted.flat_map{|c| c.errors.full_messages }.uniq.join("\n")
        redirect_to borrow_current_order_path
        raise ActiveRecord::Rollback
      end
    end
  end

  def remove
    current_user.contract_lines.unsubmitted.each(&:destroy)
    redirect_to borrow_root_path
  end

  def remove_lines(line_ids = params[:line_ids].map(&:to_i))
    lines = current_user.contract_lines.unsubmitted.find(line_ids)
    lines.each {|l| current_user.contracts.unsubmitted.each {|c| c.remove_line(l, current_user.id)} }
    redirect_to borrow_current_order_path
  end

  def timed_out
    flash[:error] = _("%d minutes passed. The items are not reserved for you any more!") % Contract::TIMEOUT_MINUTES
    @timed_out = true
    render :current
  end

  def delete_unavailables
    current_user.contract_lines.unsubmitted.each {|l| l.delete unless l.available? }
    redirect_to borrow_current_order_path, flash: {success: _("Your order has been modified. All reservations are now available.")}
  end

end
