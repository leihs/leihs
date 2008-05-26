class Backend::TakeBackController < Backend::BackendController
  
  # TODO
  def index
      @signed_contracts = Contract.signed_contracts
  end
  
end
