class Borrow::UsersController < Borrow::ApplicationController

  def current
  end

  def documents
    @contracts = current_user.contracts.includes(:contract_lines).where(status: [:signed, :closed])
    @contracts.sort! {|a,b| b.time_window_min <=> a.time_window_min}
  end

  def delegations
    @delegations = current_user.delegations
  end

  def switch_to_delegation
    if delegation = current_user.delegations.find(params[:id])
      session[:delegated_user_id] = current_user.id
      self.current_user = delegation
    end
    redirect_to borrow_root_path
  end

  ################################################################

  before_filter only: [:contract, :value_list] do
    @contract = current_user.contracts.find(params[:id])
  end

  def contract
    render "documents/contract", layout: "print"
  end

  def value_list
    render "documents/value_list", layout: "print"
  end

end
