class History < ActiveRecord::Base
  
  ACTION = 1  # Order
  CHANGE = 2  # Order
  REMIND = 3  # User
  BROKEN = 4  # Item
  
  belongs_to :target, :polymorphic => true
  belongs_to :user

  validates_presence_of :text
  
  
end
