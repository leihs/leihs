class Holiday < ActiveRecord::Base

  belongs_to :inventory_pool
  
  scope :future, where(['end_date >= ?', Date.today])
  
  before_save do
    self.end_date = self.start_date if self.end_date < self.start_date
  end
  
end

