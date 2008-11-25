class AccessRight < ActiveRecord::Base

  EVERYBODY = 1
  PRIVILEGED = 5
  
  LEVELS = {_("Everybody") => EVERYBODY, _("Privileged") => PRIVILEGED}

  belongs_to :role
  belongs_to :user
  belongs_to :inventory_pool

  validates_presence_of :user, :role
  validates_uniqueness_of :inventory_pool_id, :scope => :user_id
  validate :validates_admin_role

  def to_s
    s = "#{role.name}"
    s += " for #{inventory_pool.name}" if inventory_pool
    s
  end


  private
  
  def validates_admin_role
    if role.name == 'admin'
      errors.add_to_base(_("The admin role cannot be scoped to an inventory pool")) unless inventory_pool.nil?
    else    
      errors.add_to_base(_("Inventory Pool is missing")) if inventory_pool.nil?
    end
  end

end
