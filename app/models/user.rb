class User < ActiveRecord::Base

  serialize :extended_info

  store :settings, accessors: [ :latest_inventory_pool_id_before_logout, :start_screen ]

  belongs_to :authentication_system
  belongs_to :language
  
  has_many :access_rights, :include => :role, :conditions => "access_rights.deleted_at IS NULL" #{:deleted_at => nil}
  has_many :deleted_access_rights, :class_name => "AccessRight", :include => :role, :conditions => 'deleted_at IS NOT NULL'
  has_many :all_access_rights, :class_name => "AccessRight", :dependent => :delete_all, :include => :role
  
  has_many :inventory_pools, :through => :access_rights, :uniq => true
  has_many :active_inventory_pools, :through => :access_rights, :uniq => true, :source => :inventory_pool, :conditions => "(access_rights.suspended_until IS NULL OR access_rights.suspended_until < CURDATE())"
  has_many :suspended_inventory_pools, :through => :access_rights, :uniq => true, :source => :inventory_pool, :conditions => "access_rights.suspended_until IS NOT NULL AND access_rights.suspended_until >= CURDATE()"
  
  has_many :items, :through => :inventory_pools, :uniq => true # (nested)
  has_many :models, :through => :inventory_pools, :uniq => true # do # (nested)
    #  def inventory_pools(ips = nil)
    #    find :all, :conditions => ["inventory_pools.id IN (?)", ips] if ips
    #  end
    #end

  has_many :categories, :through => :models, :uniq => true # (nested)
  # OPTIMIZE 0907
  def all_categories
    ancestors = categories.collect(&:ancestors)
    [categories, ancestors].flatten.uniq
  end

#temp#  has_many :templates, :through => :inventory_pools
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

  has_many :notifications, :dependent => :delete_all
  
  has_many :orders, :dependent => :delete_all
  has_one  :current_order, :class_name => "Order", :conditions => { :status_const => Contract::UNSIGNED }

  has_many :contracts
  has_many :contract_lines, :through => :contracts, :uniq => true
  has_many :current_contracts, :class_name => "Contract", :conditions => { :status_const => Contract::UNSIGNED }
  has_many :visits #, :include => :inventory_pool # MySQL View based on contract_lines

  validates_presence_of     :login, :email
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :email
  validates :email, :email => true
    
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'
  has_many :reminders, :as => :target, :class_name => "History", :dependent => :destroy, :conditions => {:type_const => History::REMIND}, :order => 'created_at ASC'

  has_and_belongs_to_many :groups do #tmp#2#, :finder_sql => 'SELECT * FROM `groups` INNER JOIN `groups_users` ON `groups`.id = `groups_users`.group_id OR groups.inventory_pool_id IS NULL WHERE (`groups_users`.user_id = #{id})'
    def with_general
      all + [Group::GENERAL_GROUP_ID]
    end
  end
#tmp#1402  
#  def group_ids_including_general
#    group_ids + [Group::GENERAL_GROUP_ID]
#  end

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :phone, :address, :city, :zip, :country, :authentication_system_id, :badge_id, :language_id

################################################

  before_save do
    self.language ||= Language.default_language
  end

################################################

  SEARCHABLE_FIELDS = %w(login firstname lastname badge_id)

  scope :search, lambda { |query|
    sql = scoped
    return sql if query.blank?

=begin
    q = query.split.map{|s| "%#{s}%"}
    user_fields = User::SEARCHABLE_FIELDS.map{|f| "u.#{f}" }.join(', ')
    joins(%Q(INNER JOIN (SELECT u.id, CAST(CONCAT_WS(' ', #{user_fields}) AS CHAR) AS text
                        FROM users AS u) AS full_text ON users.id = full_text.id)).
        where(Arel::Table.new(:full_text)[:text].matches_all(q))
=end

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

  def self.filter2(options)
    sql = select("DISTINCT users.*")
    options.each_pair do |k,v|
      case k
        when :inventory_pool_id
          sql = sql.joins(:access_rights).where(:access_rights => {k => v})
      end
    end
    sql
  end

################################################

  # TODO has_many :managed_inventory_pools OR scope ??
  # get the inventory pools managed by the current user
  def managed_inventory_pools
    if has_role? "admin"
      InventoryPool.all
    else
      access_rights.managers.where("access_level >= 1").includes(:inventory_pool).collect(&:inventory_pool)
    end
  end

  def has_at_least_access_level(level, inventory_pool)
    inventory_pool and (has_role?('manager', inventory_pool, false) and access_level_for(inventory_pool) >= level)
  end

################################################

  # NOTE working for User.customers but not working for InventoryPool.first.users.customers, use InventoryPool.first.customers instead  
  scope :admins, select("DISTINCT users.*").
                  joins("LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id").
                  where(['roles.name = ? AND deleted_at IS NULL', 'admin'])

  scope :unknown_for, lambda { |inventory_pool|
    where("users.id NOT IN (#{inventory_pool.users.select("users.id").to_sql})")
  }

  # NOTE working for InventoryPool.first.users.customers (through access_rights)
  scope :customers, joins("INNER JOIN roles ON roles.id = access_rights.role_id").
                    where(:roles => {:name => "customer"})

  scope :lending_managers, joins("INNER JOIN roles ON roles.id = access_rights.role_id").
                           where(:roles => {:name => "manager"},
                                 :access_rights => {:access_level => [1,2]})

  scope :inventory_managers, joins("INNER JOIN roles ON roles.id = access_rights.role_id").
                             where(:roles => {:name => "manager"},
                                   :access_rights => {:access_level => 3})

################################################

  def to_s
    name
  end

  def name
    "#{firstname} #{lastname}"
  end
  
  def documents
    orders + contracts
  end
  
################################################

  def alternative_email
    extended_info["email_alt"] if extended_info
  end
  
  def emails
    [email, alternative_email].compact
  end

  def image_url
    if unique_id and USER_IMAGE_URL
      numeric_unique_id = unique_id.gsub(/\D/, '')
      USER_IMAGE_URL.gsub(/\{:id\}/, numeric_unique_id)
    end
  end
  
################################################

  def things_to_return
    contract_lines.to_take_back.sort {|a,b| a.end_date <=> b.end_date }
  end

  # get or create a new order (among all inventory pools)
  def get_current_order
    order = current_order
    if order.nil?
      order = orders.create(:status_const => Order::UNSUBMITTED)
      reload
    end  
    order
  end

  # get unsubmitted order lines, grouped by inventory_pool and sorted by created_at 
  def get_current_grouped_order_lines
    OrderLine.grouped_by_inventory_pool(get_current_order.order_lines)
  end

  # a user has at most one new contract for each inventory pool
  def current_contract(inventory_pool)
    contracts = current_contracts.where(:inventory_pool_id => inventory_pool)
    return nil if contracts.empty?
    if contracts.size > 1
      contracts[1..-1].each do |c|
        ContractLine.update_all({:contract_id => contracts.first.id}, {:id => c.lines})
        c.reload.destroy
      end
    end
    return contracts.first
  end
  
  # get or create a new contract for a given inventory pool
  def get_current_contract(inventory_pool)
    contract = current_contract(inventory_pool)
    if contract.nil?
      contract = contracts.create(:status_const => Contract::UNSIGNED, :inventory_pool => inventory_pool, :note => inventory_pool.default_contract_note)
      reload
    end  
    contract
  end

  # get signed contract lines, filtering the already returned lines
  def get_signed_contract_lines(inv_pool_id)
    contracts.by_inventory_pool(inv_pool_id).signed.flat_map { |c| c.contract_lines.to_take_back}
  end

####################################################################

  def access_level_for(ip)
    al = access_rights.scoped_by_inventory_pool_id(ip).not_suspended.managers.first.try(:access_level).to_i
    al = 2 if al == 1 # in leihs 3.0 we drop level 1 and we treat it as 2
    al
  end

  def access_right_for(ip)
    access_rights.scoped_by_inventory_pool_id(ip).first
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
        puts "Deadline soon: #{self.login}"
      rescue
        puts "Couldn't send reminder: #{self.login}"  
      end
    end    
  end

#################### Start role_requirement

  # ---------------------------------------
  # The following code has been generated by role_requirement.
  # You may wish to modify it to suit your need
  # modified by sellittf

  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role_in_question, inventory_pool_in_question = nil, exact_match = false)
    # retrieve roles for a given inventory_pool hierarchically with betternestedset plugin
    role = Role.where( :name => role_in_question ).first
    if inventory_pool_in_question
      roles = access_rights.scoped_by_inventory_pool_id(inventory_pool_in_question).collect(&:role)
    else
      roles = access_rights.collect(&:role)
    end
    
    if exact_match
      return roles.include?(role)
    else
      return ( roles.any? {|r| r.self_and_descendants.include?(role)} )
    end
  end
  # ---------------------------------------
  
#################### End role_requirement

  def deletable?
    orders.empty? and contracts.empty?
  end

 private

  def to_remind
    visits.take_back.where("date < CURDATE()")
  end
  
  def deadline_soon
    visits.take_back.where("date = ADDDATE(CURDATE(), 1)")
  end

end

