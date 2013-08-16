class Borrow::UsersController < Borrow::ApplicationController

  def current
  end

  def documents
    @contracts = current_user.contracts.includes(:contract_lines).where(status_const: [Contract::SIGNED, Contract::CLOSED])
    @contracts.sort! {|a,b| b.time_window_min <=> a.time_window_min}
  end

  ################################################################

  before_filter only: [:contract, :value_list] do
    @contract = current_user.contracts.find(params[:id])
    render layout: "print"
  end

  def contract
  end

  def value_list
  end

end
