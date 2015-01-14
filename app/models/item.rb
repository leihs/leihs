# encoding: utf-8
# An Item is a borrowable thing (unless being flagged as
# not being borrowable), is an instance of a #Model, has
# its own barcode and thus its own identity. This is in
# contrast to an #Option, which does not have its own
# barcode and identity.
#
# Example:
# We can have a #Model "Wild Duck Black Pather snowboard"
# and three #Items of that #Model, one which was borrowed
# and two which are still available to be taken out for
# riding pleasure. 
#
class Item < ActiveRecord::Base
  include DefaultPagination

  belongs_to :parent, class_name: "Item", foreign_key: 'parent_id', inverse_of: :children
  has_many :children, class_name: "Item", foreign_key: 'parent_id', dependent: :nullify,
                      before_add: :check_child,
                      after_add: :update_child_attributes

  belongs_to :model, inverse_of: :items
  belongs_to :location, inverse_of: :items
  belongs_to :owner, :class_name => "InventoryPool", :foreign_key => "owner_id", inverse_of: :own_items
  belongs_to :supplier
  belongs_to :inventory_pool, inverse_of: :items

  has_many :item_lines, dependent: :restrict_with_exception
  alias :contract_lines :item_lines
  has_many :histories, -> { order(:created_at) }, as: :target, dependent: :delete_all
  store :properties

####################################################################

  validates_uniqueness_of :inventory_code
  validates_presence_of :inventory_code, :model, :owner, :inventory_pool

  validate :validates_package, :validates_changes
  validates :retired_reason, presence: true, if: :retired?

####################################################################

  before_validation do
    self.owner ||= inventory_pool
    self.inventory_pool ||= owner

    self.inventory_code ||= Item.proposed_inventory_code(owner)
    self.retired_reason = nil unless retired?

    # we want remove empty values (and we keep it as HashWithIndifferentAccess)
    self.properties = properties.delete_if { |k, v| v.blank? }

    fields = Field.all.select { |field| [nil, type.downcase].include?(field.target_type) and field.attributes.has_key?(:default) }
    fields.each do |field|
      field.set_default_value(self)
    end
  end

  after_save :update_children_attributes

####################################################################

  SEARCHABLE_FIELDS = %w(inventory_code serial_number invoice_number note name user_name properties)

  scope :search, lambda { |query|
    return all if query.blank?

    q = query.split.map { |s| "%#{s}%" }
    model_fields_1 = Model::SEARCHABLE_FIELDS.map { |f| "m1.#{f}" }.join(', ')
    model_fields_2 = Model::SEARCHABLE_FIELDS.map { |f| "m2.#{f}" }.join(', ')
    item_fields_1 = Item::SEARCHABLE_FIELDS.map { |f| "i1.#{f}" }.join(', ')
    item_fields_2 = Item::SEARCHABLE_FIELDS.map { |f| "i2.#{f}" }.join(', ')
    joins(%Q(INNER JOIN (SELECT i1.id, CAST(CONCAT_WS(' ', #{model_fields_1}, #{model_fields_2}, #{item_fields_1}, #{item_fields_2}) AS CHAR) AS text
                        FROM items AS i1
                          INNER JOIN models AS m1 ON i1.model_id = m1.id
                          LEFT JOIN items AS i2 ON i2.parent_id = i1.id
                          LEFT JOIN models AS m2 ON m2.id = i2.model_id
                        ) AS full_text ON items.id = full_text.id)).
        where(Arel::Table.new(:full_text)[:text].matches_all(q))

=begin
    sql = select("DISTINCT items.*").
      joins("LEFT JOIN `models` ON `models`.`id` = `items`.`model_id`").
      joins("LEFT JOIN `inventory_pools` ON `inventory_pools`.`id` = `items`.`inventory_pool_id`")

    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(arel_table[:inventory_code].matches(q).
                      or(arel_table[:serial_number].matches(q)).
                      or(arel_table[:invoice_number].matches(q)).
                      or(arel_table[:note].matches(q)).
                      or(arel_table[:name].matches(q)).
                      or(arel_table[:user_name].matches(q)).
                      or(arel_table[:properties].matches(q)).
                      or(Model.arel_table[:name].matches(q)).
                      or(Model.arel_table[:manufacturer].matches(q)).
                      or(InventoryPool.arel_table[:name].matches(q)))
    }
    sql
=end
  }

  def self.filter(params, inventory_pool = nil)
    items = Item.all
    items = items.send(params[:type].pluralize) unless params[:type].blank?

    items = items.by_owner_or_responsible inventory_pool if inventory_pool
    items = items.where(:owner_id => inventory_pool) if params[:owned]
    items = items.where(:inventory_pool_id => params[:responsible_inventory_pool_id]) if params[:responsible_inventory_pool_id]

    items = items.where(:id => params[:ids]) if params[:ids]
    items = items.where(:id => params[:id]) if params[:id]
    items = items.retired if params[:retired] == "true"
    items = items.unretired if params[:retired] == "false"

    # there are 2 kinds of borrowable:
    # the first is item attribute
    items = items.where(is_borrowable: (params[:is_borrowable] == "true")) if params[:is_borrowable]
    # the second is item scope
    items = items.borrowable if params[:borrowable]

    items = items.unborrowable if params[:unborrowable]

    items = items.where(:model_id => Model.joins(:categories).where(:"model_groups.id" => [Category.find(params[:category_id])] + Category.find(params[:category_id]).descendants)) if params[:category_id]
    items = items.where(:parent_id => params[:package_ids]) if params[:package_ids]
    items = items.where(:parent_id => nil) if params[:not_packaged]
    items = items.joins(:model).where(models: {is_package: (params[:packages] == "true")}) if params[:packages]
    items = items.in_stock if params[:in_stock]
    items = items.incomplete if params[:incomplete]
    items = items.broken if params[:broken]
    items = items.where(:inventory_code => params[:inventory_code]) if params[:inventory_code]
    items = items.where(:model_id => params[:model_ids]) if params[:model_ids]
    items = items.search(params[:search_term]) unless params[:search_term].blank?
    items = items.default_paginate params unless params[:paginate] == "false"
    items
  end

####################################################################
# preventing delete

  def self.delete_all
    false
  end

  before_destroy do
    if model.is_package? and contract_lines.empty?
      # NOTE only never handed over packages can be deleted
    else
      errors.add(:base, "Item cannot be deleted")
      return false
    end
  end

  scope :borrowable, -> { where(:is_borrowable => true, :parent_id => nil) }
  scope :unborrowable, -> { where(:is_borrowable => false) }

  scope :retired, -> {where.not(retired: nil)}
  scope :unretired, -> {where(retired: nil)}

  scope :broken, -> { where(:is_broken => true) }
  scope :incomplete, -> { where(:is_incomplete => true) }

  scope :unfinished, -> { where(['inventory_code IS NULL OR model_id IS NULL']) }

  scope :inventory_relevant, -> { where(:is_inventory_relevant => true) }
  scope :not_inventory_relevant, -> { where(:is_inventory_relevant => false) }

  scope :packages, -> { joins(:model).where(models: {is_package: true}) }
  #temp# scope :packaged, -> {where("parent_id IS NOT NULL")}

  # Added parent_id to "in_stock" so items that are in packages are considered to not be available
  scope :in_stock, -> { joins("LEFT JOIN contract_lines AS cl001 ON items.id=cl001.item_id AND cl001.returned_date IS NULL").where("cl001.id IS NULL AND items.parent_id IS NULL") }
  scope :not_in_stock, -> { joins("INNER JOIN contract_lines AS cl001 ON items.id=cl001.item_id AND cl001.returned_date IS NULL") }

  scope :by_owner_or_responsible, lambda { |ip| where(":id IN (owner_id, inventory_pool_id)", :id => ip.id) }

  scope :items, -> { joins(:model).where(models: {type: "Model"}) }
  scope :licenses, -> { joins(:model).where(models: {type: "Software"}) }

####################################################################

  def type
    #case model.type
    case model.try :type # FIXME database consistency: there are items with model_id as nil
      when "Model", nil
        "Item"
      when "Software"
        "License"
      else
        raise "Unknown type"
    end
  end

  def to_s
    "#{model.name} #{inventory_code}"
  end

  # Generates an array suitable for outputting a line of CSV using CSV
  def to_csv_array(options = {global: false})
    if self.model.nil? or self.model.name.blank?
      model_manufacturer = "UNKNOWN" if self.model.try(:manufacturer).blank? # FIXME using model.try because database inconsistency
    else
      model_manufacturer = self.model.manufacturer.gsub(/\"/, '""') unless self.model.manufacturer.blank?
    end

    categories = []
    unless options[:global]
      unless self.model.try(:categories).nil? or self.model.categories.count == 0 # FIXME using model.try because database inconsistency
        self.model.categories.each do |c|
          categories << c.name
        end
      end
    end

    # retired = if options[:global] and self.retired? then
    #             "X"
    #           else
    #             self.retired
    #           end
    #
    # if self.parent
    #   part_of_package = "#{self.parent.id} #{self.parent.model.name}"
    # else
    #   part_of_package = "NONE"
    # end
    #
    # if ref = self.properties[:reference]
    #   case ref
    #     when "invoice"
    #       invoice = "X"
    #     when "investment"
    #       investment = "X"
    #   end
    # end

    # Using #{} notation to catch nils gracefully and silently
    h1 = {
        _("Created at") => "#{self.created_at}",
        _("Updated at") => "#{self.updated_at}",
        _("Product") => model.try(:product), # FIXME using model.try because database inconsistency
        _("Version") => model.try(:version), # FIXME using model.try because database inconsistency
        _("Manufacturer") => model_manufacturer
    }
    if type == "Item"
      h1.merge!({
                    _("Description") => model.try(:description) # FIXME using model.try because database inconsistency
                })
    end
    h1.merge!({
                  case model.try(:type) # FIXME using model.try because database inconsistency
                    when "Software"
                      _("Software Information")
                    else
                      _("Technical Details")
                  end => model.try(:technical_detail) # FIXME using model.try because database inconsistency
              })
    if type == "Item"
      h1.merge!({
                    _("Internal Description") => model.try(:internal_description), # FIXME using model.try because database inconsistency
                    _("Important notes for hand over") => model.try(:hand_over_note), # FIXME using model.try because database inconsistency
                    _("Categories") => categories.join("; "),
                    _("Accessories") => (model ? model.accessories.map(&:to_s) : []).join("; "), # FIXME using model.try because database inconsistency
                    _("Compatibles") => (model ? model.compatibles.map(&:to_s) : []).join("; "), # FIXME using model.try because database inconsistency
                    _("Properties") => (model ? model.properties.map(&:to_s) : []).join("; ") # FIXME using model.try because database inconsistency
                    # current_borrowing_information: "#{self.current_borrowing_info unless options[:global]}",
                    # part_of_package: part_of_package,
                    # needs_permission: "#{self.needs_permission}",
                    # responsible: "#{self.responsible}",
                    # location: "#{self.location}",
                    # invoice: invoice,
                    # investment: investment
                })
    end

    # we use select instead of multiple where because we need to keep the sorting
    # we exclude what is already hardcoded before (model_id as product and version)
    fields = Field.all.select do |f|
      [nil, type.downcase].include?(f.target_type) and not ['model_id'].include?(f.form_name)
    end.group_by(&:group).values.flatten

    h2 = {}
    fields.each do |field|
      h2[_(field.label)] = field.value(self)
    end
    h1.merge! h2

    h1
  end

#old??#
# def inventory_code
#   s = read_attribute('inventory_code')
#   s = "#{parent.inventory_code}/#{s}" if parent
#   s
# end

  def inv_code_with_location
    "#{inventory_code}<br/><div>#{location}</div>"
  end

####################################################################

# extract *last* number sequence in string
  def self.last_number(inventory_code)
    inventory_code ||= ""
    inventory_code.reverse.sub(/[^\d]*/, '').sub(/[^\d]+.*/, '').reverse.to_i
  end

  # proposes the next available number based on the owner inventory_pool
  # tries to take the next free inventory code after the previously created Item
  def self.proposed_inventory_code(inventory_pool)
    last_inventory_code = Item.where(:owner_id => inventory_pool).order("created_at DESC").first.try(:inventory_code)
    num = last_number(last_inventory_code)
    next_num = free_inventory_code_ranges({:from => num}).first.first
    return "#{inventory_pool.shortname}#{next_num}"
  end

  # if argument is false returns { 1 => 3, 2 => 1, 77 => 1, 79 => 2, ... }
  # the key is the allocated inventory_code_number
  # the value is the count of the allocated items
  # if the value is larger than 1, then there is a allocation conflict
  #
  # if argument is true returns { 1 => ["AVZ1", "ITZ1", "VMK1"], 2 => "AVZ2", 77 => "AVZ77", 79 => ["AVZ79", "ITZ79"], ... }
  # the key is the allocated inventory_code_number
  # the value is/are the inventory_code/s of the allocated items
  # if the value is an Array, then there is a allocation conflict
  #
  def self.allocated_inventory_code_numbers(with_allocated_codes = false)
    h = {}
    inventory_codes = ActiveRecord::Base.connection.select_values("SELECT inventory_code FROM items")
    inventory_codes.each do |code|
      num = last_number(code)
      h[num] = if with_allocated_codes
                 (h[num].nil? ? code : Array(h[num]) << code)
               else
                 h[num].to_i + 1
               end
    end
    h
  end

  def self.inventory_code_conflicts
    allocated_inventory_code_numbers(true).delete_if { |k, v| not v.is_a? Array }
  end

  # returns [ [1, 2], [5, 23], [28, 29], ... [9990, Infinity] ]
  # all displayed numbers [from, to] included are available
  #
  # Attention: params could be negative!
  #
  def self.free_inventory_code_ranges(params)
    infinity = 1/0.0
    default_params = {:from => 1, :to => infinity, :min_gap => 1}
    params.reverse_merge!(default_params)

    from = [params[:from].to_i, 1].max
    if params[:to] == infinity
      to = infinity
    else
      to = [[params[:to].to_i, from].max, infinity].min
    end
    min_gap = [[params[:min_gap].to_i, 1].max, to].min

    ranges = []
    last_n = from-1

    sorted_numbers = allocated_inventory_code_numbers.keys.select { |n| n >= from and n <= to }.sort
    sorted_numbers.each do |n|
      ranges << [last_n+1, n-1] if n-1 != last_n and (n-1 - last_n >= min_gap)
      last_n = n
    end
    ranges << [last_n+1, to] if last_n+1 <= to and (to - last_n >= min_gap)

    ranges
  end

####################################################################

# an item is in stock if it's not handed over or it's not assigned to an approved contract_line
  def in_stock?
    if parent_id
      parent.in_stock?
    else
      contract_lines.to_take_back.empty? and contract_lines.where(returned_date: nil).empty?
    end
  end

####################################################################
# TODO include Statistic module

  def current_borrowing_info
    contract_line = current_contract_line

    # FIXME this is a quick fix
    if contract_line
      _("%s until %s") % [contract_line.contract.user, contract_line.end_date.strftime("%d.%m.%Y")] # TODO 1102** patch Date.to_s => to_s(:rfc822)
    end
  end

  def current_location
    current_location = []
    current_location.push inventory_pool.to_s if inventory_pool and owner != inventory_pool
    if u = current_borrower
      current_location.push "#{u.firstname} #{u.lastname} #{_('until')} #{I18n.l(current_return_date)}"
    elsif location
      current_location.push location.to_s
    end
    current_location.join(", ")
  end

  def current_borrower
    contract_line = current_contract_line
    contract_line.contract.user if contract_line
  end

  def current_return_date
    contract_line = current_contract_line
    contract_line.end_date if contract_line
  end

  # TODO statistics
  def latest_borrower
    contract_line = latest_contract_line
    contract_line.contract.user if contract_line
  end

  # TODO statistics
  def latest_take_back_manager
  end

  private
  # TODO has_one
  def current_contract_line
    # TODO 1102** make sure is only max 1 contract_line
    contract_lines.where(:returned_date => nil).first
  end

  # TODO has_one/has_many
  def latest_contract_line
    contract_lines.where.not(returned_date: nil).order("returned_date").last
  end

  public

####################################################################

  def log_history(text, user_id)
    h = histories.create(:text => text, :user_id => user_id, :type_const => History::BROKEN)
    histories.reset if h.changed?
  end


####################################################################

  def update_children_attributes
    children.each do |child|
      update_child_attributes(child)
    end
  end

####################################################################

  # overriding attribute setter
  def retired=(v)
    if v.is_a? Date
      self[:retired] = v
    elsif [true, "true"].include? v
      if retired?
        # we keep the existing stored date
      else
        self[:retired] = Date.today
      end
    else
      self[:retired] = nil
    end
  end

  # overriding association setter
  def location_with_params=(location_attrs)
    self.location_without_params = if location_attrs.is_a? Hash
                                     location_attrs = self.location.attributes.merge location_attrs if self.location
                                     Location.find_or_create(location_attrs) unless location_attrs.blank?
                                   else
                                     location_attrs
                                   end
  end

  alias_method_chain :location=, :params

  # overriding association setter
  def supplier_with_params=(v)
    self.supplier_without_params =
        if v.is_a? Hash
          if not v[:id].blank?
            # if id is provided, then use an already existing supplier
            Supplier.find v[:id]
          elsif v[:id].blank? and not v[:name].blank?
            # if id is empty, but name is provided, then find existing or create a supplier
            Supplier.find_or_create_by(name: v[:name])
          end
          # otherwise, item.supplier is set to nil automatically
        else
          v
        end
  end

  alias_method_chain :supplier=, :params

  # overriding association setter
  def owner_with_params=(v)
    self.owner_without_params = if v.is_a? Hash
                                  InventoryPool.find(v[:id]) unless v[:id].blank?
                                else
                                  v
                                end
  end

  alias_method_chain :owner=, :params

  # overriding association setter
  def inventory_pool_with_params=(v)
    self.inventory_pool_without_params = if v.is_a? Hash
                                           InventoryPool.find(v[:id]) unless v[:id].blank?
                                         else
                                           v
                                         end
  end

  alias_method_chain :inventory_pool=, :params

####################################################################

  private

  def validates_package
    if parent_id
      if parent.nil?
        errors.add(:base, _("The parent item doesn't exist (parent_id: %d)") % parent_id)
      elsif model.is_package?
        errors.add(:base, _("A package cannot be nested to another package"))
      end
    else
      errors.add(:base, _("A package item must belong to a package model")) unless children.empty? or model.is_package

      if model.is_package? and !!retired
        children.each do |item|
          item.update_attributes(parent: nil)
        end
      end
    end
  end

  def validates_changes
    unless contract_lines.empty?
      errors.add(:base, _("The model cannot be changed because the item is used in contracts already.")) if model_id_changed?
    end
    unless in_stock?
      errors.add(:base, _("The responsible inventory pool cannot be changed because it's not returned yet or has already been assigned to a contract line.")) if inventory_pool_id_changed?
      errors.add(:base, _("The item cannot be retired because it's not returned yet or has already been assigned to a contract line.")) if not retired.nil?
    end
  end

  def update_child_attributes(item)
    item.inventory_pool = self.inventory_pool
    item.location = self.location
    item.responsible = self.responsible
    item.last_check = self.last_check
    item.properties[:ankunftsdatum] = self.properties[:ankunftsdatum]
    item.save
  end

  def check_child(child)
    raise _("A package cannot be nested to another package") if child.model.is_package?
  end

end

