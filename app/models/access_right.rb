class AccessRight < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
  belongs_to :inventory_pool

  validates_presence_of :inventory_pool, :unless => "role.name == 'admin'"

  def to_s
    s = "#{role.name}"
    s += " for #{inventory_pool.name}" if inventory_pool
    s
  end

end
