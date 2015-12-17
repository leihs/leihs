class AccessRight < ActiveRecord::Base
  audited

  belongs_to :user, inverse_of: :access_rights
  belongs_to :inventory_pool, inverse_of: :access_rights

  ####################################################################

  # NOTE the elements have to be sorted in ascending order
  ROLES_HIERARCHY = [:customer,
                     :group_manager,
                     :lending_manager,
                     :inventory_manager]
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
      # keep the existing role, just flag as deleted
      self.deleted_at = Time.zone.today
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
  validates_uniqueness_of :inventory_pool_id, scope: :user_id
  validate do
    if role.to_sym == :admin
      unless inventory_pool.nil?
        errors.add(:base,
                   _('The admin role cannot be scoped to an inventory pool'))
      end
    else
      errors.add(:base, _('Inventory Pool is missing')) if inventory_pool.nil?

      if deleted_at
        check_for_existing_reservations
      end
    end
  end

  before_validation(on: :create) do
    self.inventory_pool = nil if role.to_sym == :admin
    if user
      unless user.access_rights.active.empty?
        if inventory_pool
          old_ar = \
            user.access_rights.active.find_by(inventory_pool_id: inventory_pool.id)
        end
        user.access_rights.delete(old_ar) if old_ar
      end
    end
  end

  before_destroy do
    check_for_existing_reservations
    errors.empty?
  end

  ####################################################################

  scope :active, -> { where(deleted_at: nil) }
  scope :suspended, (lambda do
    where
      .not(suspended_until: nil)
      .where('suspended_until >= ?', Time.zone.today)
  end)

  ####################################################################

  def to_s
    s = _("#{role}".humanize)
    s += " #{_('for')} #{inventory_pool.name}" if inventory_pool
    s
  end

  def suspended?
    !suspended_until.nil? and suspended_until >= Time.zone.today
  end

  ####################################################################

  private

  def check_for_existing_reservations
    if inventory_pool
      reservations = inventory_pool.reservations.where(user_id: user)
      if reservations.submitted.exists? or reservations.approved.exists?
        errors.add(:base, _('Currently has open orders'))
      end
      if reservations.signed.exists?
        errors.add(:base, _('Currently has items to return'))
      end
    end
  end

end
