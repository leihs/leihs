class Item < ActiveRecord::Base

  AVAILABLE = 1
  IN_REPAIR = 2

  belongs_to :model
  belongs_to :inventory_pool
  has_many :contract_lines
  
  def self.find_available(id)
    find(:all, :conditions => ['model_id = ? and status = ?', id, AVAILABLE])
  end
end
