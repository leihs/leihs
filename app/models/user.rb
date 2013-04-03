# == Schema Information
#
# Table name: users
#
#  id                       :integer(4)      not null, primary key
#  login                    :string(255)
#  firstname                :string(255)
#  lastname                 :string(255)
#  phone                    :string(255)
#  authentication_system_id :integer(4)      default(1)
#  unique_id                :string(255)
#  email                    :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  badge_id                 :string(255)
#  address                  :string(255)
#  city                     :string(255)
#  zip                      :string(255)
#  country                  :string(255)
#  language_id              :integer(4)      default(1)
#  extended_info            :text
#  delta                    :boolean(1)      default(TRUE)
#

class User < ActiveRecord::Base

  serialize :extended_info

  belongs_to :authentication_system
  belongs_to :language
  
  has_many :access_rights, :include => :role, :conditions => "access_rights.deleted_at IS NULL" #{:deleted_at => nil}
  has_many :deleted_access_rights, :class_name => "AccessRight", :include => :role, :conditions => 'deleted_at IS NOT NULL'
  has_many :all_access_rights, :class_name => "AccessRight", :dependent => :delete_all, :include => :role
  
  has_many :inventory_pools, :through => :access_rights, :uniq => true
  has_many :active_inventory_pools, :through => :access_rights, :uniq => true, :source => :inventory_pool, :conditions => "(access_rights.suspended_until IS NULL OR access_rights.suspended_until < CURDATE())"
  has_many :suspended_inventory_pools, :through => :access_rights, :uniq => true, :source => :inventory_pool, :conditions => "access_rights.suspended_until IS NOT NULL AND access_rights.suspended_until >= CURDATE()"
  
  # TODO 29** has_many :managed_inventory_pools
  has_many :items, :through => :inventory_pools, :uniq => true # (nested)
  has_many :models, :through => :inventory_pools, :uniq => true # do # (nested)
    #  def inventory_pools(ips = nil)
    #    find :all, :conditions => ["inventory_pools.id IN (?)", ips] if ips
    #  end
    #end

  has_many :categories, :through => :models, :uniq => true # (nested)
  # OPTIMIZE 0907
  def all_categories
    @c = categories.collect(&:ancestors)
    [categories, @c].flatten.uniq
  end

#temp#  has_many :templates, :through => :inventory_pools
  def templates
    inventory_pools.collect(&:templates).flatten.sort
  end

  has_many :notifications, :dependent => :delete_all
  
  has_many :orders, :dependent => :delete_all
  has_one  :current_order, :class_name => "Order", :conditions => { :status_const => Contract::UNSIGNED }

  has_many :contracts
  has_many :contract_lines, :through => :contracts, :uniq => true
  has_many :current_contracts, :class_name => "Contract", :conditions => { :status_const => Contract::UNSIGNED }

  validates_presence_of     :login, :email
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :email
  # TODO: Externalize the regex to LooksLike::EMAIL_ADDR, which doesn't seem to work on some installations because
  # the are unable to find the module LooksLike from the lib/ directory on their own.
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'
  has_many :reminders, :as => :target, :class_name => "History", :dependent => :destroy, :conditions => {:type_const => History::REMIND}, :order => 'created_at ASC'

  has_and_belongs_to_many :groups #tmp#2#, :finder_sql => 'SELECT * FROM `groups` INNER JOIN `groups_users` ON `groups`.id = `groups_users`.group_id OR groups.inventory_pool_id IS NULL WHERE (`groups_users`.user_id = #{id})'
#tmp#1402  
#  def group_ids_including_general
#    group_ids + [Group::GENERAL_GROUP_ID]
#  end

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :phone, :address, :city, :zip, :country, :authentication_system_id, :badge_id, :language_id

################################################

# TODO ??  after_save :update_sphinx_index

################################################

  define_index do
    indexes :login, :sortable => true
    indexes [:firstname,:lastname], :as => :name, :sortable => true
    indexes :badge_id
    indexes :unique_id

    
    has access_rights(:inventory_pool_id), :as => :inventory_pool_id
    # has active_inventory_pools(:id), :as => :active_inventory_pool_id
    has suspended_inventory_pools(:id), :as => :suspended_inventory_pool_id
    
    #temp# has "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id", :as => :is_admin, :type => :boolean
    #temp# has access_rights.role(:name), :type => :string, :as => :role_name
    # has ... :manager_of_inventory_pool_id
    # has ... :customer_of_inventory_pool_id
    
    # set_property :order => :login
    set_property :delta => true
  end

  # sphinx_scope(:sphinx_admins) {{ :is_admin => true }}

  def touch_for_sphinx
    @block_delta_indexing = true
    touch
  end

# TODO ??
#  private
#  def update_sphinx_index
#    return if @block_delta_indexing
#    Contract.suspended_delta do
#      contracts.each {|x| x.touch_for_sphinx }
#    end
#    Order.suspended_delta do
#      orders.each {|x| x.touch_for_sphinx }
#    end
#  end
#  public

################################################

  # NOTE working for User.customers but not working for InventoryPool.first.users.customers, use InventoryPool.first.customers instead  
  named_scope :admins, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ? AND deleted_at IS NULL', 'admin']

  named_scope :managers, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ? AND deleted_at IS NULL', 'manager']

  named_scope :customers, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ? AND deleted_at IS NULL', 'customer']

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

  # OPTIMIZE
  def things_to_return
    contracts.signed.collect(&:contract_lines).flatten
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

  # a user has at most one new contract for each inventory pool
  def current_contract(inventory_pool)
    contracts = current_contracts.all(:conditions => {:inventory_pool_id => inventory_pool})
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
    contracts.by_inventory_pool(inv_pool_id).signed.collect { |c| c.contract_lines.to_take_back}.flatten
  end

####################################################################

  def access_level_for(ip)
    AccessRight.scoped_by_user_id(self).scoped_by_inventory_pool_id(ip).not_suspended.not_admin.calculate("", :access_level).to_i
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
        histories.create(:text => _("Reminded %{q} items for contracts %{c}") % { :q => visits_to_remind.collect(&:quantity).sum,
                                                                                :c => visits_to_remind.collect(&:contract_lines).flatten.collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
        puts "Reminded: #{self.name}"
      rescue
        histories.create(:text => _("Unsuccessful reminder of %{q} items for contracts %{c}") % { :q => visits_to_remind.collect(&:quantity).sum,
                                                                                :c => visits_to_remind.collect(&:contract_lines).flatten.collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
         puts "Failed to remind: #{self.name}"
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
        histories.create(:text => _("Deadline soon reminder sent for %{q} items on contracts %{c}") % { :q => visits_to_remind.collect(&:quantity).sum,
                                                                                :c => visits_to_remind.collect(&:contract_lines).flatten.collect(&:contract_id).uniq.join(',') },
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
#sellittf#  has_and_belongs_to_many :roles
# 1903**   has_many :roles, :through => :access_rights, :uniq => true
    
#sellittf#  attr_protected :roles

  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role_in_question, inventory_pool_in_question = nil, exact_match = false) #sellittf# (role_in_question)

#sellittf#
#old#
#    @_list ||= self.roles.collect(&:name)
#    return true if @_list.include?("admin")
#
#    # retrieve roles for a given inventory_pool
#    @_list = self.access_rights.collect{|a| a.role.name if a.inventory_pool.id == inventory_pool_id_in_question }
#    (@_list.include?(role_in_question.to_s) )

    # retrieve roles for a given inventory_pool hierarchically with betternestedset plugin #sellittf#
    role = Role.first(:conditions => {:name => role_in_question})
    # OPTIMIZE 1903**
    if inventory_pool_in_question
      roles = access_rights.scoped_by_inventory_pool_id(inventory_pool_in_question).collect(&:role)
    else
      # 1903** roles = self.roles
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

    
 # private

  # TODO dry with deadline_soon
  def to_remind
    lines = contract_lines.to_remind.all(:select => "end_date, contract_id, SUM(quantity) AS quantity, GROUP_CONCAT(contract_lines.id SEPARATOR ',') AS contract_line_ids",
                                         :include => {:contract => :inventory_pool},
                                         :order => "end_date",
                                         :group => "contracts.inventory_pool_id, end_date")

    lines.collect do |l|
      Event.new(:date => l.end_date, :title => "#{self.login} - #{l.contract.inventory_pool}", :quantity => l.quantity, :contract_line_ids => l.contract_line_ids.split(','),
                :inventory_pool => l.contract.inventory_pool, :user => self)
    end
  end
  
  # TODO dry with to_remind
  def deadline_soon
    lines = contract_lines.deadline_soon.all(:select => "end_date, contract_id, SUM(quantity) AS quantity, GROUP_CONCAT(contract_lines.id SEPARATOR ',') AS contract_line_ids",
                                             :include => {:contract => :inventory_pool},
                                             :order => "end_date",
                                             :group => "contracts.inventory_pool_id, end_date")

    lines.collect do |l|
      Event.new(:date => l.end_date, :title => "#{self.login} - #{l.contract.inventory_pool}", :quantity => l.quantity, :contract_line_ids => l.contract_line_ids.split(','),
                :inventory_pool => l.contract.inventory_pool, :user => self)
    end
  end

end

