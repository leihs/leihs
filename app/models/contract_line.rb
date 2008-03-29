class ContractLine < ActiveRecord::Base
  belongs_to :item
  belongs_to :contract
end
