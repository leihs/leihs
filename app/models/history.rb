# == Schema Information
#
# Table name: histories
#
#  id          :integer(4)      not null, primary key
#  text        :string(255)     default("")
#  type_const  :integer(4)
#  created_at  :datetime        not null
#  target_id   :integer(4)      not null
#  target_type :string(255)     not null
#  user_id     :integer(4)
#

class History < ActiveRecord::Base
  
  ACTION = 1      # Order
  CHANGE = 2      # Order, AccessRight
  REMIND = 3      # User
  BROKEN = 4      # Item
  
  belongs_to :target, :polymorphic => true
  belongs_to :user

  validates_presence_of :text
  
  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end  
end

