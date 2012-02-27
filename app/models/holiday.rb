# == Schema Information
#
# Table name: holidays
#
#  id                :integer(4)      not null, primary key
#  inventory_pool_id :integer(4)
#  start_date        :date
#  end_date          :date
#  name              :string(255)
#

class Holiday < ActiveRecord::Base
  belongs_to :inventory_pool
  
  scope :future, where(['end_date >= ?', Date.today])
  
  before_save do
    self.end_date = self.start_date if self.end_date < self.start_date
  end
  
end

