class InventoryPool < ActiveRecord::Base
  include Availability::InventoryPool

  belongs_to :address

  has_one :workday, :dependent => :delete
  accepts_nested_attributes_for :workday

  has_many :holidays, :dependent => :delete_all
  accepts_nested_attributes_for :holidays, :allow_destroy => true, :reject_if =>  proc {|holiday| holiday[:id]}

  has_many :access_rights, :dependent => :delete_all
  has_many :users, -> { where(access_rights: {deleted_at: nil}).uniq }, :through => :access_rights
  has_many :suspended_users, -> { where(access_rights: {deleted_at: nil}).where.not(access_rights: {suspended_until: nil}).where("access_rights.suspended_until >= ?", Date.today).uniq } , :through => :access_rights, :source => :user

  has_many :locations, -> { uniq }, :through => :items
  has_many :items, dependent: :restrict_with_exception
  has_many :own_items, :class_name => "Item", :foreign_key => "owner_id", dependent: :restrict_with_exception
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

  has_many :mail_templates, :dependent => :delete_all

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

  # we don't recalculate the past
  # if an item is already assigned, we block the availability even if the start_date is in the future
  # if an item is already assigned but not handed over, it's never considered as late even if end_date is in the past
  # we ignore the option_lines
  # we get all lines which are not yet returned
  # we ignore lines that are not handed over which the end_date is already in the past
  def running_lines
    ItemLine.find_by_sql("SELECT contract_lines.id, contracts.inventory_pool_id, model_id, quantity, start_date, end_date, " \
                            "(end_date < '#{Date.today}' AND contracts.status = '#{:signed}') AS is_late, " \
                            "IF(item_id IS NOT NULL, DATE('#{Date.today}'), IF(start_date > '#{Date.today}', start_date, DATE('#{Date.today}'))) AS unavailable_from, " \
                            "GROUP_CONCAT(groups_users.group_id) AS concat_group_ids " \
                          "FROM contract_lines " \
                          "INNER JOIN contracts ON contracts.id = contract_lines.contract_id " \
                          "LEFT JOIN groups_users ON groups_users.user_id = contracts.user_id " \
                          "WHERE contracts.inventory_pool_id = #{self.id} " \
                            "AND returned_date IS NULL " \
                            "AND contracts.status != '#{:rejected}' " \
                            "AND NOT (contracts.status = '#{:unsubmitted}' AND contracts.updated_at < '#{Time.now.utc - Contract::TIMEOUT_MINUTES.minutes}') " \
                            "AND NOT (end_date < '#{Date.today}' AND item_id IS NULL) " \
                          "GROUP BY contract_lines.id " \
                          "ORDER BY start_date, end_date, id;" ) # the order is needed by the availability computation
  end

#######################################################################

  def potential_visits
    self.class.find_by_sql %Q(SELECT c.inventory_pool_id AS inventory_pool_id,
                                     cl.start_date AS date,
                                     SUM(cl.quantity) AS quantity,
                                     c.user_id
                              FROM contract_lines AS cl JOIN contracts AS c ON cl.contract_id = c.id
                              WHERE c.status = 'submitted' AND c.inventory_pool_id = #{self.id}
                              GROUP BY c.user_id, cl.start_date, c.inventory_pool_id
                              ORDER BY cl.start_date;)
  end

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

    model_type = case params[:type]
                 when "item" then "model"
                 when "license" then "software"
                 when "option" then "option"
                 end

    model_filter_params = params.clone.merge({paginate: "false", search_targets: [:manufacturer, :product, :version, :items], type: model_type})

    # if there are NOT any params related to items
    if [:is_borrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_inventory_pool_id].all? {|param| params[param].blank?}
      # and one does not explicitly ask for software, models or used/unused models
      unless ["model", "software"].include?(model_type) or params[:used]
        # then include options
        options = Option.filter params.clone.merge({paginate: "false", sort: "product", order: "ASC"}), self
      end
    # otherwise if there is some param related to items
    else
      # don't include options and consider only used models
      model_filter_params = model_filter_params.merge({ used: "true" })
    end

    # exlude models if asked only for options
    unless model_type == "option"
      items = Item.filter params.clone.merge({paginate: "false", search_term: nil}), self
      models = Model.filter model_filter_params.merge({items: items}), self
    else
      models = []
    end

    inventory = (models + (options || [])).sort{|a,b| a.name.strip <=> b.name.strip}

    inventory = inventory.default_paginate params unless params[:paginate] == "false"
    inventory
  end

  def self.csv_export(inventory_pool, params)
    require 'csv'

    items = if inventory_pool
              Item.filter(params.clone.merge({paginate: "false", all: "true"}), inventory_pool)
            else
              Item.unscoped
            end

    options = if inventory_pool
                if params[:type] != "license" and [:unborrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_inventory_pool_id, :unused_models].all? {|param| params[param].blank?}
                  Option.filter params.clone.merge({paginate: "false", sort: "product", order: "ASC"}), inventory_pool
                else
                  []
                end
              else
                Option.unscoped
              end

    global = if inventory_pool
               false
             else
               true
             end

    include_params = [:location, :inventory_pool, :owner, :supplier]
    include_params += global ? [:model] : [:item_lines, model: [:model_links, :model_groups]]

    objects = []
    items.includes(include_params).find_each do |i, index|
      objects << i.to_csv_array(global: global) unless i.nil? # How could an item ever be nil?
    end
    unless options.blank?
      options.includes(:inventory_pool).find_each do |o|
        objects << o.to_csv_array unless o.nil? # How could an item ever be nil?
      end
    end

    csv_header = objects.flat_map(&:keys).uniq

    CSV.generate({col_sep: ";", quote_char: "\"", force_quotes: true, headers: :first_row}) do |csv|
      csv << csv_header
      objects.each do |object|
        csv << csv_header.map {|h| object[h] }
      end
    end
  end

end
