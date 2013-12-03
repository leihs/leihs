class Borrow::UsersController < Borrow::ApplicationController

  def current
  end

  def documents
    @contracts = current_user.contracts.includes(:contract_lines).where(status: [:signed, :closed])
    @contracts.sort! {|a,b| b.time_window_min <=> a.time_window_min}
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
