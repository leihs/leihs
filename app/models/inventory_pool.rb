class InventoryPool < ActiveRecord::Base

  has_many :access_rights, :dependent => :delete_all, :include => :role, :conditions => 'deleted_at IS NULL'
  has_one :workday, :dependent => :delete
  has_many :holidays, :dependent => :delete_all
  has_many :users, :through => :access_rights, :uniq => true
  has_many :suspended_users, :through => :access_rights, :uniq => true, :source => :user, :conditions => "access_rights.suspended_until IS NOT NULL AND access_rights.suspended_until >= CURDATE()"


########
#  has_many :managers, :through => :access_rights, :source => :user, :include => {:access_rights => :role}, :conditions => {:access_rights => {:roles => {:name => "manager"}}} #["access_rights.role_id = 4"]
#  has_many :managers, :class_name => "User",
#           :finder_sql => "SELECT DISTINCT u.*
#                            FROM access_rights ar
#                              LEFT JOIN users u
#                                ON ar.user_id = u.id
#                                  LEFT JOIN roles r
#                                    ON ar.role_id = r.id
#                            WHERE ar.inventory_pool_id = #{self.id} 
#                              AND r.name = 'manager'"

  # OPTIMIZE
  role_manager = Role.first(:conditions => {:name => "manager"})
  has_and_belongs_to_many :managers,
                          :class_name => "User",
                          :select => "users.*",
                          :join_table => "access_rights",
#                          :conditions => {:access_rights => {:roles => {:name => "manager"}}}
                          :conditions => ["access_rights.role_id = ? AND access_rights.deleted_at IS NULL", (role_manager ? role_manager.id : 0)]

  # OPTIMIZE
  role_customer = Role.first(:conditions => {:name => "customer"})
  has_and_belongs_to_many :customers,
                          :class_name => "User",
                          :select => "users.*",
                          :join_table => "access_rights",
#                          :conditions => {:access_rights => {:roles => {:name => "customer"}}}
                          :conditions => ["access_rights.role_id = ? AND access_rights.deleted_at IS NULL", (role_customer ? role_customer.id : 0)]
########

    
	has_many :locations, :through => :items, :uniq => true
  has_many :items, :dependent => :nullify # OPTIMIZE prevent self.destroy unless self.items.empty?
  has_many :own_items, :class_name => "Item", :foreign_key => "owner_id"
  has_many :models, :through => :items, :uniq => true
  has_many :models_active, :through => :items, :source => :model, :uniq => true, :conditions => "items.retired IS NULL" # OPTIMIZE models.active 
  has_many :own_models, :through => :own_items, :source => :model, :uniq => true
  has_many :own_models_active, :through => :own_items, :source => :model, :uniq => true, :conditions => "items.retired IS NULL" # OPTIMIZE own_models.active 
  has_many :options

  has_and_belongs_to_many :model_groups
  has_and_belongs_to_many :templates,
                          :join_table => 'inventory_pools_model_groups',
                          :association_foreign_key => 'model_group_id',
                          :conditions => {:type => 'Template'}


  has_and_belongs_to_many :accessories

  has_many :orders
  has_many :order_lines #old#, :through => :orders

  has_many :contracts
  has_many :contract_lines, :through => :contracts, :uniq => true

  has_many :groups

#######################################################################

  before_create :create_workday
  after_create  :create_general_group
  after_destroy :destroy_general_group
# TODO ??  after_save :update_sphinx_index

  validates_presence_of :name

  default_scope :order => "name"

#######################################################################

  define_index do
    indexes :name, :sortable => true
    indexes :description

    has access_rights(:user_id), :as => :user_id

    # set_property :order => :name
    set_property :delta => true
  end

#######################################################################

  def to_s
    "#{name}"
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name.casecmp other.name
  end

#######################################################################
  
  def closed_days
    workday.closed_days
  end
  
  def closed_dates
    ["01.01.2009"] #TODO **24** Get the dates from Holidays, put them in the correct format (depends on DatePicker)
  end
  
  # OPTIMIZE used for extjs
  def items_size(model_id)
    items.borrowable.scoped_by_model_id(model_id).count
  end

  def is_open_on?(date)
    workday.is_open_on?(date) and not holiday?(date)
  end

  def holiday?(date)
    holidays.each do |h|
      return true if date >= h.start_date and date <= h.end_date
    end
    return false
  end
###################################################################################
  
  # TODO dry with take_back_visits
  def hand_over_visits(max_start_date = nil)
    lines = contract_lines.to_hand_over.all(:select => "start_date, contract_id, SUM(quantity) AS quantity, GROUP_CONCAT(contract_lines.id SEPARATOR ',') AS contract_line_ids",
                                            :include => {:contract => :user},
                                            :conditions => (max_start_date ? ["start_date <= ?", max_start_date] : nil),
                                            :order => "start_date",
                                            :group => "contracts.user_id, start_date")

    lines.collect do |l|
      Event.new(:date => l.start_date, :title => l.contract.user.login, :quantity => l.quantity, :contract_line_ids => l.contract_line_ids.split(','),
                :inventory_pool => self, :user => l.contract.user)
    end
  end

  # TODO dry with hand_over_visits
  def take_back_visits(max_end_date = nil)
    lines = contract_lines.to_take_back.all(:select => "end_date, contract_id, SUM(quantity) AS quantity, GROUP_CONCAT(contract_lines.id SEPARATOR ',') AS contract_line_ids",
                                            :include => {:contract => :user},
                                            :conditions => (max_end_date ? ["end_date <= ?", max_end_date] : nil),
                                            :order => "end_date",
                                            :group => "contracts.user_id, end_date")

    lines.collect do |l|
      Event.new(:date => l.end_date, :title => l.contract.user.login, :quantity => l.quantity, :contract_line_ids => l.contract_line_ids.split(','),
                :inventory_pool => self, :user => l.contract.user)
    end
  end

###################################################################################

  def has_access?(user)
    user.inventory_pools.include?(self)
  end
  
  def is_blacklisted?(user)
    suspended_users.count(:conditions => {:id => user.id}) > 0
  end

  def add_to_general_group( user )
    groups.general.users << user unless groups.general.users.exisist?( user )
  end
  
###################################################################################

private
  
# TODO ??
#  def update_sphinx_index
#    Item.suspended_delta do
#      items.each {|x| x.touch }
#    end
#    User.suspended_delta do
#      users.each {|x| x.touch }
#    end
#    ModelGroup.suspended_delta do
#      model_groups.each {|x| x.touch }
#    end
#  end

  def create_general_group
    Group.create :name => 'General', :inventory_pool_id => self.id
  end
  
  def destroy_general_group
    self.groups.general.destroy
  end

end
