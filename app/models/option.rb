class Option < ActiveRecord::Base
  
  belongs_to :contract
  
  validates_presence_of :name
  validates_presence_of :quantity
  
  
  def to_s
    "#{quantity} - #{name}"
  end
end
