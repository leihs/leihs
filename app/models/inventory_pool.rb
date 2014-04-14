class InventoryPool < ActiveRecord::Base
  include Availability::InventoryPool

  belongs_to :address

  has_one :workday, :dependent => :delete
  accepts_nested_attributes_for :workday

  has_many :holidays, :dependent => :delete_all
  accepts_nested_attributes_for :holidays, :allow_destroy => true, :reject_if =>  proc {|holiday| holiday[:id]}

  has_many :access_rights, :dependent => :delete_all
  has_many :users, -> { where(access_rights: {deleted_at: nil}).uniq }, :through => :access_rights
  has_many :suspended_users, -> { where("access_rights.deleted_at IS NULL AND access_rights.suspended_until IS NOT NULL AND access_rights.suspended_until >= CURDATE()").uniq } , :through => :access_rights, :source => :user

  has_many :locations, -> { uniq }, :through => :items
  has_many :items, :dependent => :nullify # OPTIMIZE prevent self.destroy unless self.items.empty? 
                                          # NOTE these are only the active items (unretired), because Item has a default_scope
  has_many :own_items, :class_name => "Item", :foreign_key => "owner_id", :dependent => :restrict_with_exception
  has_many :models, -> { uniq }, :through => :items
  has_many :options

  has_and_belongs_to_many :model_groups
  has_and_belongs_to_many :templates, -> { where(:type => 'Template') },
                          :join_table => 'inventory_pools_model_groups',
                          :association_foreign_key => 'model_group_id'


  has_and_belongs_to_many :accessories

  has_many :contracts, :dependent => :restrict_with_exception
  has_many :contract_lines, -> { uniq }, :through => :contracts #Rails3.1# TODO still needed?
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

    def array_for_model_and_groups(model, groups)
      group_ids = groups.map{|x| x.try(:id) }
      select{|p| p.model_id == model.id and group_ids.include? p.group_id}
    end
  end

  has_many :running_lines, -> { order(:start_date, :end_date, :type, :id) } # the order is needed by the availability computation TODO sort directly on to the sql-view ??

#######################################################################

  validates_presence_of :name, :shortname, :email
  validates_presence_of :automatic_suspension_reason, if: :automatic_suspension?

  validates_uniqueness_of :name

  validates :email, format: /@/, allow_blank: true

#######################################################################

  scope :search, lambda { |query|
    sql = all
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

  def inventory(params)
    items = Item.filter params.clone.merge({paginate: "false", all: "true", search_term: nil}), self

    if [:unborrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_id, :unused_models].all? {|param| params[param].blank?}
      options = Option.filter params.clone.merge({paginate: "false", sort: "product", order: "ASC"}), self
    end

    item_ids = items.pluck(:id)

    models = Model.filter params.clone.merge({paginate: "false", item_ids: item_ids, include_retired_models: params[:retired], search_targets: [:manufacturer, :product, :version, :items]}), self

    inventory = (models + (options || [])).sort{|a,b| a.name.strip <=> b.name.strip}
    inventory = inventory.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"

    inventory
  end

end
