class AccessRight < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
  belongs_to :inventory_pool


  def to_s
    "#{role.name} for #{inventory_pool.name}"
  end

end
