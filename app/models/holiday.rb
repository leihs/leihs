class Holiday < ActiveRecord::Base
  belongs_to :inventory_pool
  
  named_scope :future, :conditions => ['end_date > ?', Date.today]
  
  before_save :end_date_is_bigger_than_start_date
  
  def end_date_is_bigger_than_start_date
    self.end_date = self.start_date if self.end_date < self.start_date
  end
  
end
