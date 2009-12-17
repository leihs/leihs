class AccessRight < ActiveRecord::Base

  CUSTOMER = 1
  EMPLOYEE = 3
  SPECIAL = 5
  
  LEVELS = {_("Customer") => CUSTOMER, _("Employee") => EMPLOYEE, _("Special") => SPECIAL }

  belongs_to :role
  belongs_to :user
  belongs_to :inventory_pool

  validates_presence_of :user, :role
  validates_uniqueness_of :inventory_pool_id, :scope => :user_id
  validate :validates_admin_role

  before_validation_on_create :remove_old

  named_scope :by_inventory_pool, lambda { |inventory_pool| { :conditions => {:inventory_pool_id => inventory_pool} } }

####################################################################

  def to_s
    s = "#{role.name}"
    s += " for #{inventory_pool.name}" if inventory_pool
    s += " (Borrow Level: #{level.to_i}, Access Level: #{access_level.to_i})"
    s
  end

  def suspended?
    suspended_at != nil
  end

  def deactivate
    update_attributes(:deleted_at => DateTime.now)
  end

  private
  
  def validates_admin_role
    if role.name == 'admin'
      errors.add_to_base(_("The admin role cannot be scoped to an inventory pool")) unless inventory_pool.nil?
    else    
      errors.add_to_base(_("Inventory Pool is missing")) if inventory_pool.nil?
    end
  end

  def remove_old
    self.inventory_pool = nil if role.name == 'admin'
    unless user.access_rights.empty?
      old_ar = user.access_rights.first(:conditions => { :inventory_pool_id => inventory_pool.id }) if inventory_pool
      user.access_rights.delete(old_ar) if old_ar
    end
  end

end
