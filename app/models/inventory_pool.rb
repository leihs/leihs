class InventoryPool < ActiveRecord::Base
  include Availability::InventoryPool

  belongs_to :address

  has_one :workday, :dependent => :delete
  accepts_nested_attributes_for :workday

  has_many :holidays, :dependent => :delete_all
  accepts_nested_attributes_for :holidays, :allow_destroy => true, :reject_if =>  proc {|holiday| holiday[:id]}

  has_many :access_rights, :dependent => :delete_all, :include => :role, :conditions => 'deleted_at IS NULL'
  has_many :users, :through => :access_rights, :uniq => true
  has_many :suspended_users, :through => :access_rights, :uniq => true, :source => :user, :conditions => "access_rights.suspended_until IS NOT NULL AND access_rights.suspended_until >= CURDATE()"

  has_many :locations, :through => :items, :uniq => true
  has_many :items, :dependent => :nullify # OPTIMIZE prevent self.destroy unless self.items.empty? 
                                          # NOTE these are only the active items (unretired), because Item has a default_scope
  has_many :own_items, :class_name => "Item", :foreign_key => "owner_id", :dependent => :restrict
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

  has_many :orders, :dependent => :delete_all
  has_many :order_lines #old#, :through => :orders

  has_many :contracts, :dependent => :restrict
  has_many :contract_lines, :through => :contracts, :uniq => true #Rails3.1# TODO still needed?
  has_many :visits #, :include => {:user => [:reminders, :groups]} # MySQL View based on contract_lines

  has_many :groups do #tmp#2#, :finder_sql => 'SELECT * FROM `groups` WHERE (`groups`.inventory_pool_id = #{id} OR `groups`.inventory_pool_id IS NULL)'
    def with_general
      all + [Group::GENERAL_GROUP_ID]
    end
  end

  before_create :create_workday

#######################################################################

  # MySQL View based on partitions and items
  has_many :partitions_with_generals do
    # we use array select instead of sql where condition to fetch once all partitions during the same request, instead of hit the db multiple times
    # returns a hash as {group_id => quantity} like {nil => 10, 41 => 3, 42 => 6, ...}
    def hash_for_model_and_groups(model, groups = nil)
      a = select{|p| p.model_id == model.id}
      if groups
        group_ids = groups.map{|x| x.try(:id) }
        a = a.select{|p| group_ids.include? p.group_id}
      end
      h = Hash[a.map{|p| [p.group_id, p.quantity] }]
      h = {Group::GENERAL_GROUP_ID => 0} if h.empty?
      h
    end
    alias :hash_for_model :hash_for_model_and_groups

    def array_for_model_and_groups(model, groups)
      group_ids = groups.map{|x| x.try(:id) }
      select{|p| p.model_id == model.id and group_ids.include? p.group_id}
    end
  end

  has_many :running_lines, :order => [:start_date, :end_date, :type, :id] # the order is needed by the availability computation TODO sort directly on to the sql-view ??

#######################################################################

  def used_root_categories
    models.flat_map(&:categories).flat_map{|x| x.ancestors.roots }.uniq
  end
  
#######################################################################

  validates_presence_of :name, :shortname, :email

  validates_uniqueness_of :name

  default_scope order("name")

  validates :email, format: /@/, allow_blank: true

#######################################################################

  scope :search, lambda { |query|
    sql = scoped
    return sql if query.blank?
    
    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(arel_table[:name].matches(q).
                      or(arel_table[:description].matches(q)))
    }
    sql
  }

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
    if workday.closed_days.size < 7
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
    if workday.closed_days.size < 7
      while not is_open_on?(x) do
        holiday = running_holiday_on(x)
        if holiday
          x = holiday.start_date.yesterday
        else
          x -= 1.day
        end
      end
    end
    x
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
    suspended_users.where(:id => user.id).exists?
  end

###################################################################################

  def update_address(attr)
    if (a = Address.where(attr).first)
      update_attributes(:address_id => a.id)
    else
      create_address(attr)
    end
  end

  def create_workday
    self.workday ||= Workday.new
  end 
  
end
