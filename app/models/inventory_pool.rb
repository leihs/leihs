class InventoryPool < ActiveRecord::Base

  has_many :access_rights, :dependent => :delete_all, :include => :role, :conditions => 'deleted_at IS NULL'
  has_one :workday, :dependent => :delete
  has_many :holidays, :dependent => :delete_all
  has_many :users, :through => :access_rights, :uniq => true
  has_many :suspended_users, :through => :access_rights, :uniq => true, :source => :user, :conditions => "access_rights.suspended_at IS NOT NULL"


#working here#
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

  # FIXME working here
  role_manager = Role.first(:conditions => {:name => "manager"})
  has_and_belongs_to_many :managers,
                          :class_name => "User",
                          :select => "users.*",
                          :join_table => "access_rights",
#                          :conditions => {:access_rights => {:roles => {:name => "manager"}}}
                          :conditions => ["access_rights.role_id = ? AND access_rights.deleted_at IS NULL", (role_manager ? role_manager.id : 0)]

  # FIXME working here
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

#######################################################################

  before_create :create_workday
# TODO ??  after_save :update_index

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
  
  def hand_over_visits
    #unless @ho_visits  # OPTIMIZE refresh if new contracts become available
      @ho_visits = []

      ids = contracts.unsigned.collect(&:id)
      lines = ContractLine.all(:conditions => {:contract_id => ids})

      lines.each do |l|
        v = @ho_visits.detect { |w| w.user == l.contract.user and w.date == l.start_date }
        unless v
          @ho_visits << Event.new(:start => l.start_date, :end => l.end_date, :title => l.contract.user.login, :isDuration => false, :action => "hand_over", :inventory_pool => l.contract.inventory_pool, :user => l.contract.user, :contract_lines => [l])
        else
          v.contract_lines << l
        end
      end
      
      @ho_visits.sort!
    #end
    @ho_visits
  end

  def take_back_visits
   @tb_visits ||= take_back_or_remind_visits
  end

  def remind_visits
   @r_visits ||= take_back_or_remind_visits(:remind => true)
  end

###################################################################################

  def has_access?(user)
    user.inventory_pools.include?(self)
  end
  
  def is_blacklisted?(user)
    suspended_users.count(:conditions => {:id => user.id}) > 0
  end
  
###################################################################################

  private
  
  def take_back_or_remind_visits(remind = false)
    visits = []
    
    ids = contracts.signed.collect(&:id)
    if remind
      lines = ContractLine.to_remind.all(:conditions => {:contract_id => ids})
    else
      lines = ContractLine.to_take_back.all(:conditions => {:contract_id => ids})
    end

    lines.each do |l|
      v = visits.detect { |w| w.user == l.contract.user and w.date == l.end_date }
      unless v
        visits << Event.new(:start => l.end_date, :end => l.end_date, :title => l.contract.user.login, :isDuration => false, :action => "take_back", :inventory_pool => l.contract.inventory_pool, :user => l.contract.user, :contract_lines => [l])
      else
        v.contract_lines << l
      end
    end
    
    visits.sort!
  end

# TODO ??
#  def update_index
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

end
