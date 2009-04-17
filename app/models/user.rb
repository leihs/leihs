class User < ActiveRecord::Base
  
  belongs_to :authentication_system
  has_many :access_rights, :dependent => :delete_all, :include => :role # OPTIMIZE N+1 select problem
  has_many :inventory_pools, :through => :access_rights, :uniq => true
  # TODO 29** has_many :managed_inventory_pools
  has_many :items, :through => :inventory_pools, :uniq => true # (nested)
  has_many :models, :through => :inventory_pools, :uniq => true # do # (nested)


    #  def inventory_pools(ips = nil)
    #    find :all, :conditions => ["inventory_pools.id IN (?)", ips] if ips
    #  end
    #end
  has_many :categories, :through => :models, :uniq => true # (nested)
  def all_categories # TODO optimize
    @c = []
    categories.each do |c|
       @c << c.parents.recursive.to_a
    end
    @c.flatten.uniq
  end

#old#  has_many :templates, :through => :models, :uniq => true # TODO 08** alternatively define an association directly between <Template belongs_to InventoryPool>
# TODO 12** real association
#temp#  has_many :templates, :through => :inventory_pools
  def templates
    inventory_pools.collect(&:templates).flatten.sort
  end

  has_many :notifications, :dependent => :delete_all
  
  has_many :orders, :dependent => :delete_all
  has_one  :current_order, :class_name => "Order", :conditions => ["status_const = ?", Contract::NEW]

  has_many :contracts
  has_many :contract_lines, :through => :contracts, :uniq => true
  has_many :current_contracts, :class_name => "Contract", :conditions => ["status_const = ?", Contract::NEW]

  validates_presence_of     :login, :email
  validates_length_of       :login,    :within => 3..100
  validates_uniqueness_of   :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'
  has_many :reminders, :as => :target, :class_name => "History", :dependent => :destroy, :conditions => {:type_const => History::REMIND}, :order => 'created_at ASC'

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :phone, :authentication_system_id

# 0603**
  acts_as_ferret :fields => [ :login, :firstname, :lastname ], :store_class_name => true, :remote => true
#  define_index do
#    indexes login
#    indexes firstname
#    indexes lastname
#    has :id
#    has access_rights(:inventory_pool_id), :as => :inventory_pool_id
## 0603** set_property :delta => true
#  end

################################################

  # NOTE working for User.customers but not working for InventoryPool.first.users.customers, use InventoryPool.first.customers instead  
  named_scope :admins, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ?', 'admin']

  named_scope :managers, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ?', 'manager']

  named_scope :customers, :select => "DISTINCT users.*",
                       :joins => "LEFT JOIN access_rights ON access_rights.user_id = users.id LEFT JOIN roles ON roles.id = access_rights.role_id",
                       :conditions => ['roles.name = ?', 'customer']

################################################

  def to_s
    login
  end

  def name
    "#{firstname} #{lastname}"
  end

################################################

  # OPTIMIZE
  def things_to_return
    contracts.signed_contracts.collect(&:contract_lines).flatten
  end

  # get or create a new order (among all inventory pools)
  def get_current_order
    order = current_order
    if order.nil?
      order = orders.create(:status_const => Order::NEW)
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
      contract = contracts.create(:status_const => Contract::NEW, :inventory_pool => inventory_pool, :note => inventory_pool.default_contract_note)
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
      e << Event.new(:start => l.start_date, :end => l.end_date, :title =>l.model.name)
    end
    e.sort
  end

  def visits
    e = []
    contracts.new_contracts.each do |c|
      c.lines.each do |l|
        v = e.detect { |w| w.date == l.start_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(:start => l.start_date, :end => l.start_date, :title => "#{self.login} - #{c.inventory_pool.name}", :isDuration => false, :action => "hand_over", :inventory_pool => c.inventory_pool, :user => self, :contract_lines => [l])
        else
          v.contract_lines << l
        end
      end
    end

    contracts.signed_contracts.each do |c|
      c.lines.each do |l|
        v = e.detect { |w| w.date == l.end_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(:start => l.end_date, :end => l.end_date, :title => "#{self.login} - #{c.inventory_pool.name}", :isDuration => false, :action => "take_back", :inventory_pool => c.inventory_pool, :user => self, :contract_lines => [l])
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
    access_right = access_rights.detect { |ar| ar.role.id > 1 and ar.inventory_pool.id == ip.id}
    access_right.nil? ? 0 : access_right.level
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
      Notification.remind_user(self, visits_to_remind)
      histories.create(:text => _("Reminded %{q} items for contracts %{c}") % { :q => visits_to_remind.collect(&:quantity).sum,
                                                                                :c => visits_to_remind.collect(&:contract_lines).flatten.collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
      puts "Reminded: #{self.name}"
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
      Notification.deadline_soon_reminder(self, visits_to_remind)
      histories.create(:text => _("Deadline soon reminder sent for %{q} items on contracts %{c}") % { :q => visits_to_remind.collect(&:quantity).sum,
                                                                                :c => visits_to_remind.collect(&:contract_lines).flatten.collect(&:contract_id).uniq.join(',') },
                       :user_id => reminder_user,
                       :type_const => History::REMIND)
      puts "Deadline soon: #{self.login}"
    end    
  end

#################### Start role_requirement

  # ---------------------------------------
  # The following code has been generated by role_requirement.
  # You may wish to modify it to suit your need
#sellittf#  has_and_belongs_to_many :roles
  
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
      roles = self.access_rights.collect{|a| a.role if a.inventory_pool and a.inventory_pool.id == inventory_pool_in_question.id }.compact
    else
      roles = self.access_rights.collect(&:role)
    end
    
    if exact_match
      return roles.include?(role)
    else
      return ( roles.any? {|r| r.full_set.include?(role)} )
    end
  end
  # ---------------------------------------
  
#################### End role_requirement

    
 # private
  
  def to_remind
    e = []
    contracts.signed_contracts.each do |c|
      c.lines.to_remind.each do |l|
        v = e.detect { |w| w.date == l.end_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(:start => l.end_date, :end => l.end_date, :title => "#{self.login} - #{c.inventory_pool.name}", :isDuration => false, :action => "take_back", :inventory_pool => c.inventory_pool, :user => self, :contract_lines => [l])
        else
          v.contract_lines << l
        end
      end
    end
    e.sort
  end
  
  def deadline_soon(date = Date.tomorrow)
    e = []
    contracts.signed_contracts.each do |c|
      c.lines.deadline_soon.each do |l|
        v = e.detect { |w| w.date == l.end_date and w.inventory_pool == c.inventory_pool }
        unless v
          e << Event.new(:start => l.end_date, :end => l.end_date, :title => "#{self.login} - #{c.inventory_pool.name}", :isDuration => false, :action => "take_back", :inventory_pool => c.inventory_pool, :user => self, :contract_lines => [l])
        else
          v.contract_lines << l
        end
      end
    end
    e.sort    
  end
  
end
