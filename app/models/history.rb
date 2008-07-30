class History < ActiveRecord::Base
  
  ACTION = 1
  CHANGE = 2
  REMIND = 3
  
  belongs_to :target, :polymorphic => true
  belongs_to :user
  
end
