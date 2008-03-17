class OrderLine < ActiveRecord::Base
  belongs_to :model
  belongs_to :order
end
