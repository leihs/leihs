# == Schema Information
#
# Table name: inventory_pools
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  description           :text
#  contact_details       :string(255)
#  contract_description  :string(255)
#  contract_url          :string(255)
#  logo_url              :string(255)
#  default_contract_note :text
#  shortname             :string(255)
#  email                 :string(255)
#  color                 :text
#  delta                 :boolean(1)      default(TRUE)
#  print_contracts       :boolean(1)      default(TRUE)
#

class InventoryPool < ActiveRecord::Base
  include Availability::InventoryPool

  belongs_to :address
  has_one :workday, :dependent => :delete
  has_many :holidays, :dependent => :delete_all

  has_many :access_rights, :dependent => :delete_all, :include => :role, :conditions => 'deleted_at IS NULL'
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

#rails3#tmp#
#  # OPTIMIZE
#  role_manager = Role.where(:name => "manager").first
#  has_and_belongs_to_many :managers,
#                          :class_name => "User",
#                          :select => "users.*",
#                          :join_table => "access_rights",
##                          :conditions => {:access_rights => {:roles => {:name => "manager"}}}
#                          :conditions => ["access_rights.role_id = ? AND access_rights.deleted_at IS NULL", (role_manager ? role_manager.id : 0)]
#
#  # OPTIMIZE
#  role_customer = Role.where(:name => "customer").first
#  has_and_belongs_to_many :customers,
#                          :class_name => "User",
#                          :select => "users.*",
#                          :join_table => "access_rights",
##                          :conditions => {:access_rights => {:roles => {:name => "customer"}}}
#                          :conditions => ["access_rights.role_id = ? AND access_rights.deleted_at IS NULL", (role_customer ? role_customer.id : 0)]
########

    
	has_many :locations, :through => :items, :uniq => true
  has_many :items, :dependent => :nullify # OPTIMIZE prevent self.destroy unless self.items.empty? 
                                          # NOTE these are only the active items (unretired), because Item has a default_scope
  has_many :own_items, :class_name => "Item", :foreign_key => "owner_id"
  #TODO  do we need a :all_items ??
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
  has_many :contract_lines, :through => :contracts, :uniq => true #Rails3.1# TODO still needed?
  has_many :visits, :include => :user # MySQL View based on contract_lines

  has_many :groups #tmp#2#, :finder_sql => 'SELECT * FROM `groups` WHERE (`groups`.inventory_pool_id = #{id} OR `groups`.inventory_pool_id IS NULL)'

#######################################################################

  def used_root_categories
    models.map(&:categories).flatten.map{|x| x.ancestors.roots }.flatten.uniq
  end
  
#######################################################################

  before_create :create_workday

# TODO ??  after_save :update_sphinx_index

  validates_presence_of :name

  default_scope order("name")

  # TODO: Externalize the regex to LooksLike::EMAIL_ADDR, which doesn't seem to work on some installations because
  # the are unable to find the module LooksLike from the lib/ directory on their own.
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true

#######################################################################

  define_index do
    indexes :name, :sortable => true
    indexes :description

    has access_rights(:user_id), :as => :user_id

    # set_property :order => :name
    set_property :delta => true
  end

  def touch_for_sphinx
    @block_delta_indexing = true
    save # trigger reindex
  end

# TODO ??
#  private
#  def update_sphinx_index
#    return if @block_delta_indexing
#    Item.suspended_delta do
#      items.each {|x| x.touch_for_sphinx }
#    end
#    User.suspended_delta do
#      users.each {|x| x.touch_for_sphinx }
#    end
#    ModelGroup.suspended_delta do
#      model_groups.each {|x| x.touch_for_sphinx }
#    end
#  end
#  public

#######################################################################

  def to_s
    "#{name}"
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name.casecmp other.name
  end

#######################################################################

  def next_open_date(x = Date.today)
    if closed_days.size < 7
      while not is_open_on?(x) do
        holiday = running_holiday_on(x)
        if holiday
          x = holiday.end_date.tomorrow
        else
          x += 1.day
        end
      end
    end
    x
  end
  
  def last_open_date(x = Date.today)
    if closed_days.size < 7
      while not is_open_on?(x) do
        holiday = running_holiday_on(x)
        if holiday
          x = holiday.end_date.tomorrow
        else
          x -= 1.day
        end
      end
    end
    x
  end
  
  def closed_days
    workday.closed_days
  end
  
  def closed_dates
    ["01.01.2009"] #TODO **24** Get the dates from Holidays, put them in the correct format (depends on DatePicker)
  end
  
  def is_open_on?(date)
    workday.is_open_on?(date) and running_holiday_on(date).nil?
  end

  def running_holiday_on(date)
    holidays.where(["start_date <= :d AND end_date >= :d", {:d => date}]).first
  end
  
###################################################################################

  def has_access?(user)
    user.inventory_pools.include?(self)
  end
  
  def is_blacklisted?(user)
    suspended_users.where(:id => user.id).count > 0
  end

###################################################################################

  def update_address(attr)
    if (a = Address.where(attr).first)
      ip.update_attributes(:address_id => a.id)
    else
      ip.create_address(attr)
    end
  end

###################################################################################

end
