class Borrow::UsersController < Borrow::ApplicationController

  def current
    if current_user.authentication_system.class_name == "DatabaseAuthentication"
      @db_auth = DatabaseAuthentication.find_by_user_id(current_user.id)
    end
  end

  def documents
    @contracts = current_user.contracts.signed_or_closed
    @contracts.sort! {|a,b| b.time_window_min <=> a.time_window_min}
  end

  def delegations
    @delegations = current_user.delegations.customers
  end

  def switch_to_delegation
    if delegation = current_user.delegations.find(params[:id])
      session[:delegated_user_id] = current_user.id
      self.current_user = delegation
    end
    redirect_to borrow_root_path
  end

  def switch_back
    if current_user.delegated_users.exists? @current_delegated_user
      session[:delegated_user_id] = nil
      self.current_user = @current_delegated_user
      @current_delegated_user = nil
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
