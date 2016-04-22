class User < ActiveRecord::Base
  include Delegation::User
  include DefaultPagination
  audited

  serialize :extended_info

  store :settings, accessors: [:latest_inventory_pool_id_before_logout,
                               :start_screen]

  belongs_to :authentication_system
  belongs_to :language

  has_many :access_rights, dependent: :restrict_with_exception
  has_many(:inventory_pools,
           -> { where(access_rights: { deleted_at: nil }).uniq },
           through: :access_rights) do
    def with_borrowable_items
      joins(:items)
        .where(items: { retired: nil, is_borrowable: true, parent_id: nil })
    end

    # get the inventory pools managed by the current user
    def managed(role = [:inventory_manager, :lending_manager, :group_manager])
      where(access_rights: { role: role })
    end
  end

  has_many :items, -> { uniq }, through: :inventory_pools
  has_many(:models, -> { uniq }, through: :inventory_pools) do
    def borrowable
      # TODO: dry with_borrowable_items
      joins(:items)
        .where(items: { retired: nil, is_borrowable: true, parent_id: nil })
        .joins("INNER JOIN (#{Partition.query}) AS pwg " \
               'ON `models`.`id` = `pwg`.`model_id` ' \
               'AND `inventory_pools`.`id` = `pwg`.`inventory_pool_id` ' \
               'AND `pwg`.`quantity` > 0 ' \
               'AND (`pwg`.`group_id` IN ' \
                 '(SELECT `group_id` FROM `groups_users` ' \
                 "WHERE `user_id` = #{proxy_association.owner.id}) " \
                   'OR `pwg`.`group_id` IS NULL)')
    end
  end

  has_many(:categories, -> { uniq }, through: :models) do
    def with_borrowable_items
      where(items: { retired: nil, is_borrowable: true, parent_id: nil })
      .joins("INNER JOIN (#{Partition.query}) AS pwg " \
             'ON `models`.`id` = `pwg`.`model_id` ' \
             'AND `inventory_pools`.`id` = `pwg`.`inventory_pool_id` ' \
             'AND `pwg`.`quantity` > 0 ' \
             'AND (`pwg`.`group_id` IN ' \
               '(SELECT `group_id` FROM `groups_users` ' \
               "WHERE `user_id` = #{proxy_association.owner.id}) " \
                 'OR `pwg`.`group_id` IS NULL)')
    end
  end

  def all_categories
    borrowable_categories = categories.with_borrowable_items

    ancestors = \
      Category \
        .joins('INNER JOIN `model_group_links` ' \
               'ON `model_groups`.`id` = `model_group_links`.`ancestor_id`')
        .where(model_group_links: \
                 { descendant_id: borrowable_categories.pluck(:id) })
        .uniq

    [borrowable_categories, ancestors].flatten.uniq
  end

  # temp#  has_many :templates, :through => :inventory_pools
  def templates
    inventory_pools.flat_map(&:templates).sort
  end

  def start_screen(path = nil)
    if path
      self.settings[:start_screen] = path
      return self.save
    else
      self.settings[:start_screen]
    end
  end

  has_many :notifications, dependent: :delete_all

  has_many :reservations, dependent: :restrict_with_exception
  has_many :reservations_bundles, -> { extending BundleFinder }
  # TODO: ?? # has_many :contracts, through: :reservations_bundles
  has_many :item_lines, dependent: :restrict_with_exception
  has_many :option_lines, dependent: :restrict_with_exception
  has_many :visits

  validates_presence_of :firstname
  validates_presence_of :lastname, :email, :login, unless: :delegation?
  validates_length_of :login, within: 2..255, unless: :delegation?
  validates_uniqueness_of :email, unless: :delegation?
  validates :email, format: /.+@.+\..+/, allow_blank: true

  # tmp#2#, :finder_sql => 'SELECT * FROM `groups`
  # INNER JOIN `groups_users` ON `groups`.id = `groups_users`.group_id
  # OR groups.inventory_pool_id IS NULL WHERE (`groups_users`.user_id = #{id})'
  has_and_belongs_to_many :groups do
    def with_general
      to_a + [Group::GENERAL_GROUP_ID]
    end
  end

  has_many :hidden_fields, dependent: :destroy

  ################################################

  before_save do
    self.language ||= Language.default_language
  end

  after_create do
    ips = InventoryPool.where(automatic_access: true)
    ips.each do |ip|
      access_rights.create(role: :customer, inventory_pool: ip)
    end
  end

  ################################################

  SEARCHABLE_FIELDS = %w(login firstname lastname badge_id)

  scope :search, lambda { |query|
    sql = all
    return sql if query.blank?

    sql = sql.uniq.joins(
      'LEFT JOIN (`delegations_users` AS `du`, `users` AS `u2`) ' \
      'ON (`du`.`delegation_id` = `users`.`id` AND `du`.`user_id` = `u2`.`id`)'
    )
    u2_table = Arel::Table.new(:u2)

    query.split.each do|q|
      q = "%#{q}%"
      sql = sql.where(arel_table[:login].matches(q)
                      .or(arel_table[:firstname].matches(q))
                      .or(arel_table[:lastname].matches(q))
                      .or(arel_table[:badge_id].matches(q))
                      .or(arel_table[:unique_id].matches(q))
                      .or(u2_table[:login].matches(q))
                      .or(u2_table[:firstname].matches(q))
                      .or(u2_table[:lastname].matches(q))
                      .or(u2_table[:badge_id].matches(q))
                      .or(u2_table[:unique_id].matches(q))
                     )
    end
    sql
  }

  def self.filter(params, inventory_pool = nil)
    # NOTE if params[:role] == "all" is provided,
    # then we have to skip the deleted access_rights,
    # so we fetch directly from User
    # NOTE the case of fetching users with specific ids
    # from a specific inventory_pool is still missing,
    # might be necessary in future
    if inventory_pool and params[:all].blank?
      users = if params[:suspended] == 'true'
                inventory_pool.suspended_users
              else
                inventory_pool.users
              end
      unless params[:delegation_id].blank?
        users = users.find(params[:delegation_id]).delegated_users
      end
      users = users.send params[:role] unless params[:role].blank?
    else
      users = all
    end

    users = users.admins if params[:role] == 'admins'
    users = users.as_delegations if params[:type] == 'delegation'
    users = users.not_as_delegations if params[:type] == 'user'
    users = users.where(id: params[:ids]) if params[:ids]
    users = users.search(params[:search_term]) if params[:search_term]
    users = users.order(User.arel_table[:firstname].asc)
    users = users.default_paginate params unless params[:paginate] == 'false'
    users
  end

  ################################################

  scope(:admins,
        (lambda do
          joins(:access_rights)
            .where(access_rights: { role: :admin, deleted_at: nil })
        end))

  AccessRight::ROLES_HIERARCHY.each do |role|
    scope(role.to_s.pluralize.to_sym,
          -> { joins(:access_rights).where(access_rights: { role: role }).uniq })
  end

  ################################################

  def to_s
    name
  end

  def name
    "#{firstname} #{lastname}".strip
  end

  def short_name
    if delegation?
      name
    else
      "#{firstname[0]}. #{lastname}"
    end
  end

  ################################################

  def email
    if delegation?
      delegator_user.email
    else
      read_attribute(:email)
    end
  end

  def alternative_email
    extended_info['email_alt'] if extended_info
  end

  def emails
    [email, alternative_email].compact.uniq
  end

  def image_url
    if Setting.user_image_url
      if Setting.user_image_url.match(/\{:id\}/) and unique_id
        Setting.user_image_url.gsub(/\{:id\}/, unique_id)
      elsif Setting.user_image_url.match(/\{:extended_info:id\}/) \
        and extended_info \
        and extended_info['id']
        Setting.user_image_url.gsub(/\{:extended_info:id\}/,
                                    extended_info['id'].to_s)
      end
    end
  end

  def address
    read_attribute(:address).try(:chomp, ', ')
  end

  ################################################

  def self.remind_and_suspend_all
    # TODO: dry
    grouped_reservations = \
      Visit
        .take_back_overdue
        .flat_map(&:reservations)
        .group_by do |vl|
          { inventory_pool: vl.inventory_pool,
            user_id: (vl.delegated_user_id || vl.user_id) }
        end
    grouped_reservations.each_pair do |k, reservations|
      user = User.find(k[:user_id])
      user.remind(reservations)
    end
    # TODO: dry
    grouped_reservations = \
      Visit
        .take_back_overdue
        .flat_map(&:reservations)
        .group_by do |vl|
          { inventory_pool: vl.inventory_pool, user_id: vl.user_id }
        end
    grouped_reservations.each_pair do |k, reservations|
      user = User.find(k[:user_id])
      user.automatic_suspend(k[:inventory_pool])
    end
  end

  def self.send_deadline_soon_reminder_to_everybody
    grouped_reservations = \
      Visit
        .take_back
        .where('date = ?', Date.tomorrow)
        .flat_map(&:reservations)
        .group_by do |vl|
          { inventory_pool: vl.inventory_pool,
            user_id: (vl.delegated_user_id || vl.user_id) }
        end
    grouped_reservations.each_pair do |k, reservations|
      user = User.find(k[:user_id])
      user.send_deadline_soon_reminder(reservations)
    end
  end

  def automatic_suspend(inventory_pool)
    if inventory_pool.automatic_suspension? and not suspended?(inventory_pool)
      access_right_for(inventory_pool).update_attributes \
        suspended_until: AccessRight::AUTOMATIC_SUSPENSION_DATE,
        suspended_reason: inventory_pool.automatic_suspension_reason
      puts "Suspended: #{self.name} on #{inventory_pool} for overdue take back"
    end
  end

  def remind(reservations)
    unless reservations.empty?
      begin
        Notification.remind_user(self, reservations)
        puts "Reminded: #{self.name}"
        true
      rescue Exception => exception
        puts "Failed to remind: #{self.name}"
        # archive problem in the log, so the admin/developper
        # can look up what happened
        logger.error "#{exception}\n    #{exception.backtrace.join("\n    ")}"
        false
      end
    end
  end

  def send_deadline_soon_reminder(reservations, _reminder_user = self)
    unless reservations.empty?
      begin
        Notification.deadline_soon_reminder(self, reservations)
        puts "Deadline soon: #{self.name}"
      rescue
        puts "Couldn't send reminder: #{self.name}"
      end
    end
  end

  #################### Start role_requirement

  # TODO: refactor has_role? to role?
  # rubocop:disable Style/PredicateName
  def has_role?(role, inventory_pool = nil)
    role = role.to_sym
    if role == :admin
      access_rights.active.where(role: role).exists?
    else
      roles = if inventory_pool
                access_rights.where(inventory_pool_id: inventory_pool)
              else
                access_rights
              end.active.collect(&:role)

      if AccessRight::ROLES_HIERARCHY.include? role
        i = AccessRight::ROLES_HIERARCHY.index role
        (roles & AccessRight::ROLES_HIERARCHY).any? do |r|
          AccessRight::ROLES_HIERARCHY.index(r) >= i
        end
      else
        roles.include? role
      end
    end
  end
  # rubocop:enable Style/PredicateName

  def access_right_for(ip)
    access_rights.active.find_by(inventory_pool_id: ip)
  end

  def suspended?(ip)
    access_rights.active.suspended.where(inventory_pool_id: ip).exists?
  end

  #################### End role_requirement

  def deletable?
    reservations_bundles.empty? and access_rights.active.empty?
  end

  ############################################

  def timeout?
    reservations
      .unsubmitted
      .where('updated_at < ?',
             Time.zone.now - Setting.timeout_minutes.minutes)
      .exists?
  end

end
