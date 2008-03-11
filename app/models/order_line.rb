class OrderLine < ActiveRecord::Base
  belongs_to :type
  belongs_to :order
end
