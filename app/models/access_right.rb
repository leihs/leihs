class AccessRight < ActiveRecord::Base

  belongs_to :role
  belongs_to :user
  belongs_to :inventory_pool
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  validates_presence_of :user, :role
  validates_uniqueness_of :inventory_pool_id, :scope => :user_id
  validate do
    if role.name == 'admin'
      errors.add(:base, _("The admin role cannot be scoped to an inventory pool")) unless inventory_pool.nil?
    else
      errors.add(:base, _("Inventory Pool is missing")) if inventory_pool.nil?
    end
  end

  before_validation(:on => :create) do
    self.inventory_pool = nil if role.name == 'admin'
    unless user.access_rights.empty?
      old_ar = user.access_rights.where( :inventory_pool_id => inventory_pool.id ).first if inventory_pool
      user.access_rights.delete(old_ar) if old_ar
    end
  end

  before_save do
    case role.name
      when "admin", "customer"
        self.access_level = nil
      when "manager"
        self.access_level = [access_level.to_i, 1].max
    end
  end
  
  scope :not_suspended, where("suspended_until IS NULL OR suspended_until < CURDATE()")
  scope :managers, joins(:role).where(:roles => {:name => "manager"}, :deleted_at => nil)
  
####################################################################

  def to_s
    s = "#{role.name}"
    s += " for #{inventory_pool.name}" if inventory_pool
    #s += " (#{_("Access Level: %d") % access_level.to_i})" if role.name == "manager"
    s += ("(" + _("Access Level: %d") % access_level.to_i + ")") if role.name == "manager"
    s
  end

  def role_name
    case role.name
      when "admin", "customer"
        role.name
      when "manager"
        case access_level
          when 1, 2
            "lending_manager"
          when 3
            "inventory_manager"
        end
    end
  end

  def role_name=(v)
    case v
      when "customer"
        self.role = Role.find_by_name("customer")
      when "lending_manager"
        self.role = Role.find_by_name("manager")
        self.access_level = 2
      when "inventory_manager"
        self.role = Role.find_by_name("manager")
        self.access_level = 3
    end
  end

  def suspended?
    !suspended_until.nil? and suspended_until >= Date.today
  end

  def deactivate
    update_attributes(:deleted_at => DateTime.now)
  end

end
