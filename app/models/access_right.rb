class AccessRight < ActiveRecord::Base
  belongs_to :role
  belongs_to :permission
  belongs_to :inventory_pool
end
