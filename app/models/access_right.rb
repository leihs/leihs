class AccessRight < ActiveRecord::Base

  belongs_to :user, inverse_of: :access_rights
  belongs_to :inventory_pool, inverse_of: :access_rights
  has_many :histories, -> { order('created_at ASC') }, as: :target, dependent: :delete_all

####################################################################

  # NOTE the elements have to be sorted in ascending order
  ROLES_HIERARCHY = [:customer, :group_manager, :lending_manager, :inventory_manager]
  AVAILABLE_ROLES = ROLES_HIERARCHY + [:admin]

  AUTOMATIC_SUSPENSION_DATE = Date.new(2099, 1, 1)

  def role
    read_attribute(:role).to_sym
  end

  def role=(v)
    v = v.to_sym
    self.deleted_at = nil unless v == :no_access
    case v
      when :admin, :customer, :group_manager, :lending_manager, :inventory_manager
        write_attribute(:role, v)
      when :no_access
        self.deleted_at = Date.today # keep the existing role, just flag as deleted
    end

    # assigning a new role, reactivate (ensure is not deleted)
    if role_changed?
      case v
        when :admin, :customer, :group_manager, :lending_manager, :inventory_manager
          self.deleted_at = nil
      end
    end
  end

####################################################################

  validates_presence_of :user, :role
  validates_presence_of :suspended_reason, if: :suspended_until?
  validates_uniqueness_of :inventory_pool_id, :scope => :user_id
  validate do
    if role.to_sym == :admin
      errors.add(:base, _("The admin role cannot be scoped to an inventory pool")) unless inventory_pool.nil?
    else
      errors.add(:base, _("Inventory Pool is missing")) if inventory_pool.nil?

      if deleted_at
        lines = inventory_pool.contract_lines.by_user(user)
        errors.add(:base, _("Currently has open orders")) if lines.to_approve.exists? or lines.to_hand_over.exists?
        errors.add(:base, _("Currently has items to return")) if lines.to_take_back.exists?
      end
    end
  end

  before_validation(:on => :create) do
    self.inventory_pool = nil if role.to_sym == :admin
    if user
      unless user.access_rights.active.empty?
        old_ar = user.access_rights.active.where( :inventory_pool_id => inventory_pool.id ).first if inventory_pool
        user.access_rights.delete(old_ar) if old_ar
      end
    end
  end

  before_destroy do
    raise _("Currently has things to return") if inventory_pool and not inventory_pool.contract_lines.by_user(user).to_take_back.empty?
  end

####################################################################

  scope :active, -> { where(deleted_at: nil) }
  scope :suspended, -> { where("suspended_until IS NOT NULL AND suspended_until >= ?", Date.today) }
  scope :not_suspended, -> { where("suspended_until IS NULL OR suspended_until < ?", Date.today) }

####################################################################

  def to_s
    s = _("#{role}".humanize)
    s += " #{_("for")} #{inventory_pool.name}" if inventory_pool
    s
  end

  def suspended?
    !suspended_until.nil? and suspended_until >= Date.today
  end

  #def deactivate
  #  update_attributes(:deleted_at => DateTime.now)
  #end

end
