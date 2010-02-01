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
  validate :validates_inventory_pool

  before_validation_on_create :remove_old
  before_save :adjust_levels
  after_save :update_index

  default_scope :include => :inventory_pool, :order => "inventory_pools.name", :conditions => "deleted_at IS NULL"

####################################################################

  def to_s
    s = "#{role.name}"
    s += " for #{inventory_pool.name}" if inventory_pool
    unless role.name == "admin"
      l = []
      l << _("Borrow Level: %d") % level.to_i
      l << _("Access Level: %d") % access_level.to_i unless role.name == "customer"
      s += " (#{l.join(', ')})"
    end
    s
  end

  def suspended?
    suspended_at != nil
  end

  def deactivate
    update_attributes(:deleted_at => DateTime.now)
  end

####################################################################

  private

  def validates_inventory_pool
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

  def adjust_levels
    case role.name
      when "admin"
        self.access_level = self.level = nil
      when "manager"
        self.level = [level.to_i, 1].max
        self.access_level = [access_level.to_i, 1].max
      when "customer"
        self.level = [level.to_i, 1].max
        self.access_level = nil
    end
  end

  def update_index
    user.touch
    inventory_pool.touch if inventory_pool
  end

end
