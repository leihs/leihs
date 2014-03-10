class User < ActiveRecord::Base

  serialize :extended_info

  store :settings, accessors: [ :latest_inventory_pool_id_before_logout, :start_screen ]

  belongs_to :authentication_system
  belongs_to :language

  has_many :access_rights, :dependent => :restrict_with_exception
  has_many :inventory_pools, -> { where(access_rights: {deleted_at: nil}).uniq }, :through => :access_rights do
    def with_borrowable_items
      joins(:items).where(items: {retired: nil, is_borrowable: true, parent_id: nil})
    end
  end

  has_many :items, -> { uniq }, :through => :inventory_pools
  has_many :models, -> { uniq }, :through => :inventory_pools do
    def borrowable
      joins("INNER JOIN `partitions_with_generals` ON `models`.`id` = `partitions_with_generals`.`model_id`
                                                  AND `inventory_pools`.`id` = `partitions_with_generals`.`inventory_pool_id`
                                                  AND `partitions_with_generals`.`quantity` > 0
                                                  AND (`partitions_with_generals`.`group_id` IN (SELECT `group_id` FROM `groups_users` WHERE `user_id` = #{proxy_association.owner.id}) OR `partitions_with_generals`.`group_id` IS NULL)")
    end
  end

  has_many :categories, -> { uniq }, :through => :models # (nested)

  def all_categories
    borrowable_categories = Category.with_borrowable_models_for_user(self)

    ancestors = Category.joins("INNER JOIN `model_group_links` ON `model_groups`.`id` = `model_group_links`.`ancestor_id`").
                  where(:model_group_links => {:descendant_id => borrowable_categories}).uniq

    [borrowable_categories, ancestors].flatten.uniq
  end

  #temp#  has_many :templates, :through => :inventory_pools
  def templates
    inventory_pools.flat_map(&:templates).sort
  end

  def short_name
    "#{firstname[0]}. #{lastname}"
  end

  def start_screen(path = nil)
    if path
      self.settings[:start_screen] = path
      return self.save
    else
      self.settings[:start_screen]
    end
  end

  has_many :notifications, :dependent => :delete_all

  has_many :contracts, dependent: :restrict_with_exception
  has_many :contract_lines, -> { uniq }, :through => :contracts
  has_many :visits #, :include => :inventory_pool # MySQL View based on contract_lines

  validates_presence_of     :lastname, :firstname, :email, :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :email
  validates :email, format: /.+@.+\..+/, allow_blank: true

  has_many :histories, -> { order(:created_at) }, :as => :target, :dependent => :destroy
  has_many :reminders, -> { where(:type_const => History::REMIND).order(:created_at) }, :as => :target, :class_name => "History", :dependent => :destroy

  has_and_belongs_to_many :groups do #tmp#2#, :finder_sql => 'SELECT * FROM `groups` INNER JOIN `groups_users` ON `groups`.id = `groups_users`.group_id OR groups.inventory_pool_id IS NULL WHERE (`groups_users`.user_id = #{id})'
    def with_general
      all + [Group::GENERAL_GROUP_ID]
    end
  end

################################################

  before_save do
    self.language ||= Language.default_language
  end

################################################

  SEARCHABLE_FIELDS = %w(login firstname lastname badge_id)

  scope :search, lambda { |query|
    sql = scoped
    return sql if query.blank?

    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(arel_table[:login].matches(q).
                      or(arel_table[:firstname].matches(q)).
                      or(arel_table[:lastname].matches(q)).
                      or(arel_table[:badge_id].matches(q)).
                      or(arel_table[:unique_id].matches(q)))
    }
    sql
  }

  def self.filter(params, inventory_pool = nil)
    # NOTE if params[:role] == "all" is provided, then we have to skip the deleted access_rights, so we fetch directly from User
    # NOTE the case of fetching users with specific ids from a specific inventory_pool is still missing, might be necessary in future
    if inventory_pool and params[:all].blank?
      users = params[:suspended] == "true" ? inventory_pool.suspended_users : inventory_pool.users
      users = users.send params[:role] unless params[:role].blank?
    else
      users = scoped
    end

    users = users.admins if params[:role] == "admins"
    users = users.where(id: params[:ids]) if params[:ids]
    users = users.search(params[:search_term]) if params[:search_term]
    users = users.order(User.arel_table[:firstname].asc)
    users = users.paginate(:page => params[:page] || 1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
    users
  end

################################################

  # TODO has_many :managed_inventory_pools OR scope ??
  # get the inventory pools managed by the current user
  def managed_inventory_pools(role = [:inventory_manager, :lending_manager, :group_manager])
    if has_role? :admin
      InventoryPool.all
    else
      access_rights.active.where(role: role).includes(:inventory_pool).collect(&:inventory_pool)
    end
  end

################################################

  scope :admins, -> {joins(:access_rights).where(access_rights: {role: :admin, deleted_at: nil})}

  AccessRight::ROLES_HIERARCHY.each do |role|
    scope role.to_s.pluralize.to_sym, -> {joins(:access_rights).where(access_rights: {role: role}).uniq}
  end

################################################

  def to_s
    name
  end

  def name
    "#{firstname} #{lastname}"
  end

  def documents
    contracts
  end

################################################

  def alternative_email
    extended_info["email_alt"] if extended_info
  end

  def emails
    [email, alternative_email].compact.uniq
  end

  def image_url
    if unique_id and Setting::USER_IMAGE_URL
      Setting::USER_IMAGE_URL.gsub(/\{:id\}/, unique_id)
      Setting::USER_IMAGE_URL.gsub(/\{:extended_info:id\}/, extended_info["id"].to_s) if extended_info
    end
  end

################################################

  # get or create a new unsubmitted contract for a specific inventory_pool
  def get_unsubmitted_contract(inventory_pool)
    contract = contracts.unsubmitted.where(inventory_pool_id: inventory_pool).first
    unless contract
      contract = contracts.create(status: :unsubmitted, inventory_pool: inventory_pool)
      reload
    end
    contract
  end

  # a user has at most one approved contract for each inventory pool
  def approved_contract(inventory_pool)
    contracts = self.contracts.where(:inventory_pool_id => inventory_pool, :status => :approved)
    return nil if contracts.empty?
    if contracts.size > 1
      contracts[1..-1].each do |c|
        c.contract_lines.update_all(:contract_id => contracts.first.id)
        c.reload.destroy
      end
    end
    return contracts.first
  end

  # get or create a new contract for a given inventory pool
  def get_approved_contract(inventory_pool)
    contract = approved_contract(inventory_pool)
    if contract.nil?
      contract = contracts.create(:status => :approved, :inventory_pool => inventory_pool, :note => inventory_pool.default_contract_note)
      reload
    end
    contract
  end

####################################################################

  def self.remind_all
    User.all.each do |u|
      u.remind
    end
  end


  def remind(reminder_user = self)
    visits_to_remind = to_remind
    unless visits_to_remind.empty?
      begin
        Notification.remind_user(self, visits_to_remind)
        histories.create(:text => _("Reminded %{q} items for contracts %{c}") % { :q => visits_to_remind.sum(:quantity),
                                                                                :c => visits_to_remind.flat_map(&:contract_lines).collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
        puts "Reminded: #{self.name}"
        return true
      rescue Exception => exception
        histories.create(:text => _("Unsuccessful reminder of %{q} items for contracts %{c}") % { :q => visits_to_remind.sum(:quantity),
                                                                                :c => visits_to_remind.flat_map(&:contract_lines).collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
         puts "Failed to remind: #{self.name}"

         # archive problem in the log, so the admin/developper
         # can look up what happened
         logger.error "#{exception}\n    #{exception.backtrace.join("\n    ")}"
         return false
      end
    end
  end

  def to_remind?
    not to_remind.empty?
  end

  def self.send_deadline_soon_reminder_to_everybody
    User.all.each do |u|
      u.send_deadline_soon_reminder
    end
  end

  def send_deadline_soon_reminder(reminder_user = self)
    visits_to_remind = deadline_soon
    unless visits_to_remind.empty?
      begin
        Notification.deadline_soon_reminder(self, visits_to_remind)
        histories.create(:text => _("Deadline soon reminder sent for %{q} items on contracts %{c}") % { :q => visits_to_remind.sum(:quantity),
                                                                                :c => visits_to_remind.flat_map(&:contract_lines).collect(&:contract_id).uniq.join(',') },
                         :user_id => reminder_user,
                         :type_const => History::REMIND)
        puts "Deadline soon: #{self.name}"
      rescue
        puts "Couldn't send reminder: #{self.name}"
      end
    end
  end

#################### Start role_requirement

  def has_role?(role, inventory_pool = nil)
    roles = if inventory_pool
      access_rights.active.where(inventory_pool_id: inventory_pool).collect(&:role)
    else
      access_rights.active.collect(&:role)
    end

    if AccessRight::ROLES_HIERARCHY.include? role
      i = AccessRight::ROLES_HIERARCHY.index role
      (roles & AccessRight::ROLES_HIERARCHY).any? {|r| AccessRight::ROLES_HIERARCHY.index(r) >= i }
    else
      roles.include? role
    end
  end

  def access_right_for(ip)
    access_rights.active.where(inventory_pool_id: ip).first
  end

  def suspended?(ip)
    access_rights.active.suspended.where(inventory_pool_id: ip).exists?
  end

#################### End role_requirement

  def deletable?
    contracts.empty? and access_rights.active.empty?
  end

  ############################################

  def timeout?
    # NOTE the second check is superfluous in case we ensure there are no empty contracts
    if contracts.unsubmitted.empty? or contracts.unsubmitted.flat_map(&:lines).empty?
      false
    else
      (Time.now - contracts.unsubmitted.first.updated_at) > Contract::TIMEOUT_MINUTES.minutes
    end
  end

  ############################################

 private

  def to_remind
    visits.take_back.where("date < CURDATE()")
  end

  def deadline_soon
    visits.take_back.where("date = ADDDATE(CURDATE(), 1)")
  end

end

