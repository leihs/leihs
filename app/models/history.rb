class History < ActiveRecord::Base
  
  ACTION = 1      # Order
  CHANGE = 2      # Order, AccessRight
  REMIND = 3      # User
  BROKEN = 4      # Item
  
  belongs_to :target, polymorphic: true, inverse_of: :histories
  belongs_to :user

  validates_presence_of :text
  
  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end  
end

