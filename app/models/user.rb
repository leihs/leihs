class User < ActiveRecord::Base
  
  belongs_to :authentication_system
  has_many :access_rights, :dependent => :delete_all
#  has_many :roles, :through => :access_rights, :uniq => true
  has_many :inventory_pools, :through => :access_rights, :uniq => true
  has_many :items, :through => :inventory_pools, :uniq => true # (nested)
  has_many :models, :through => :inventory_pools, :uniq => true # do # (nested)
    #  def inventory_pools(ips = nil)
    #    find :all, :conditions => ["inventory_pools.id IN (?)", ips] if ips
    #  end
    #end
  has_many :categories, :through => :models, :uniq => true # (nested)
  has_many :notifications
  # TODO has_many :templates, :through => :models, :uniq => true # (nested)

  def all_categories # TODO optimize
    @c = []
    categories.each do |c|
       @c << c.parents.recursive.to_a
    end
    @c.flatten.uniq
  end
  
  has_many :orders
  has_one  :current_order, :class_name => "Order", :conditions => ["status_const = ?", Contract::NEW]

  has_many :contracts
  has_many :contract_lines, :through => :contracts, :uniq => true
  has_many :current_contracts, :class_name => "Contract", :conditions => ["status_const = ?", Contract::NEW]

  validates_presence_of     :login #TODO: is Email mandatory? , :email
  validates_length_of       :login,    :within => 3..100
  #TODO is Email mandatory? validates_length_of       :email,    :within => 3..100

  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'
  has_many :reminders, :as => :target, :class_name => "History", :dependent => :destroy, :conditions => {:type_const => History::REMIND}, :order => 'created_at ASC'

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  acts_as_ferret :fields => [ :login ], :store_class_name => true, :remote => true

################################################

  # NOTE working for User.students but not working for InventoryPool.first.users.students, use InventoryPool.first.students instead  
  named_scope :admins, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ?', 'admin']

  named_scope :managers, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ?', 'manager']

  named_scope :students, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ?', 'student']

################################################

  def to_s
    login
  end

################################################

  # get or create a new order (among all inventory pools)
  def get_current_order
    order = current_order
    if order.nil?
      order = Order.create(:user => self, :status_const => Order::NEW)
      reload
    end  
    order
  end

  # a user has at most one new contract for each inventory pool
  def current_contract(inventory_pool)
    current_contracts.detect {|c| c.inventory_pool == inventory_pool } # OPTIMIZE
  end
  
  # get or create a new contract for a given inventory pool
  def get_current_contract(inventory_pool)
    contract = current_contract(inventory_pool)
    if contract.nil?
      contract = Contract.create(:user => self, :status_const => Contract::NEW, :inventory_pool => inventory_pool)
      reload
    end  
    contract
  end

  # get signed contract lines, filtering the already returned lines
  def get_signed_contract_lines
    contracts.signed_contracts.collect { |c| c.contract_lines.to_take_back }.flatten
  end

####################################################################

  def events
    e = []
    contract_lines.each do |l|
      e << Event.new(l.start_date, l.end_date, l.model.name)
    end
    e.sort
  end

  def visits
    e = []
    contracts.new_contracts.each do |c|
      c.lines.each do |l|
        v = e.detect { |w| w.date == l.start_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(l.start_date, l.start_date, "#{self.login} - #{c.inventory_pool.name}", false, "hand_over", c.inventory_pool, self, l)
        else
          v.contract_lines << l
        end
      end
    end

    contracts.signed_contracts.each do |c|
      c.lines.each do |l|
        v = e.detect { |w| w.date == l.end_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(l.end_date, l.end_date, "#{self.login} - #{c.inventory_pool.name}", false, "take_back", c.inventory_pool, self, l)
        else
          v.contract_lines << l
        end
      end
    end

    e.sort   
  end

  
  def timeline
    xml = Event.xml_wrap(events)
    
    f_name = "/javascripts/timeline/user_#{self.id}.xml"
    File.open("public#{f_name}", 'w') { |f| f.puts xml }
    f_name
  end

  def timeline_visits
    xml = Event.xml_wrap(visits)
    
    f_name = "/javascripts/timeline/user_#{self.id}_visits.xml"
    File.open("public#{f_name}", 'w') { |f| f.puts xml }
    f_name
  end


  def level_for(ip)
    ar = access_rights.detect { |ar| ar.role.id > 1 and ar.inventory_pool.id == ip.id}
    ar.nil? ? 0 : ar.level
  end

####################################################################

  # TODO call from cron >>> ./script/runner User.remind_all
  def self.remind_all
    User.all.each do |u|
      puts u.remind
    end
  end

  def remind(reminder_user = self)
    visits_to_remind = to_remind
    m = ""
    unless visits_to_remind.empty?
      Notification.remind_user(self, visits_to_remind)
      histories.create(:text => _("Reminded %{q} items for contracts %{c}") % { :q => visits_to_remind.collect(&:quantity).sum,
                                                                                :c => visits_to_remind.collect(&:contract_lines).flatten.collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
    end
    m
  end
  
  def to_remind?
    not to_remind.empty?
  end

#################### Start role_requirement

  # ---------------------------------------
  # The following code has been generated by role_requirement.
  # You may wish to modify it to suit your need
#sellittf#  has_and_belongs_to_many :roles
  
#sellittf#  attr_protected :roles

  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role_in_question, inventory_pool_in_question = nil) #sellittf# (role_in_question)
#sellittf#    @_list ||= self.roles.collect(&:name)
#sellittf#    return true if @_list.include?("admin")

#old# retrieve roles for a given inventory_pool
#sellittf#    @_list = self.access_rights.collect{|a| a.role.name if a.inventory_pool.id == inventory_pool_id_in_question }
#sellittf#    (@_list.include?(role_in_question.to_s) )

# retrieve roles for a given inventory_pool hierarchically with betternestedset plugin #sellittf#
    role = Role.find(:first, :conditions => {:name => role_in_question})
    if inventory_pool_in_question
      roles = self.access_rights.collect{|a| a.role if a.inventory_pool and a.inventory_pool.id == inventory_pool_in_question.id }.compact
    else
      roles = self.access_rights.collect(&:role)
    end  
    ( roles.any? {|r| r.full_set.include?(role)} )
  end
  # ---------------------------------------
  
#################### End role_requirement

    
  private
  
  def to_remind
    e = []
    contracts.signed_contracts.each do |c|
      c.lines.to_remind.each do |l|
        v = e.detect { |w| w.date == l.end_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(l.end_date, l.end_date, "#{self.login} - #{c.inventory_pool.name}", false, "take_back", c.inventory_pool, self, l)
        else
          v.contract_lines << l
        end
      end
    end
    e.sort
  end
    
end
