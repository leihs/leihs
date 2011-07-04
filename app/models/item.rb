# == Schema Information
#
# Table name: items
#
#  id                    :integer(4)      not null, primary key
#  inventory_code        :string(255)
#  serial_number         :string(255)
#  model_id              :integer(4)
#  location_id           :integer(4)
#  supplier_id           :integer(4)
#  owner_id              :integer(4)
#  parent_id             :integer(4)
#  invoice_number        :string(255)
#  invoice_date          :date
#  last_check            :date
#  retired               :date
#  retired_reason        :string(255)
#  price                 :decimal(8, 2)
#  is_broken             :boolean(1)      default(FALSE)
#  is_incomplete         :boolean(1)      default(FALSE)
#  is_borrowable         :boolean(1)      default(FALSE)
#  created_at            :datetime
#  updated_at            :datetime
#  needs_permission      :boolean(1)      default(FALSE)
#  inventory_pool_id     :integer(4)
#  is_inventory_relevant :boolean(1)      default(TRUE)
#  responsible           :string(255)
#  insurance_number      :string(255)
#  note                  :text
#  name                  :text
#  delta                 :boolean(1)      default(TRUE)
#

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
  
  belongs_to :parent, :class_name => "Item", :foreign_key => 'parent_id'
  has_many :children, :class_name => "Item", :foreign_key => 'parent_id', :dependent => :nullify,
                      :after_add => :update_child_attributes
  
  belongs_to :model
  belongs_to :location
  belongs_to :owner, :class_name => "InventoryPool", :foreign_key => "owner_id"
  belongs_to :supplier
  belongs_to :inventory_pool
  
  has_many :contract_lines
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

####################################################################

  validates_uniqueness_of :inventory_code
  validates_presence_of :inventory_code, :model
  validate :validates_package, :validates_model_change, :validates_retired

####################################################################

  before_save do |record|
    record.owner = record.inventory_pool if record.inventory_pool and !record.owner
  end

  after_save :update_sphinx_index, :update_children_attributes

####################################################################

  define_index do
    # 0501 where "retired IS NULL"
    
    # 0501 where "parent_id IS NULL"
    # 0501 indexes childen...
    
    indexes :inventory_code, :sortable => true
    indexes :serial_number #, :sortable => true
    indexes model(:name), :as => :model_name, :sortable => true 
    indexes model(:manufacturer), :as => :model_manufacturer #, :sortable => true
    indexes inventory_pool(:name), :as => :inventory_pool_name #, :sortable => true 
    indexes :invoice_number
    indexes :note
    indexes :name

    has :is_borrowable, :is_broken, :is_incomplete, :is_inventory_relevant, :type => :boolean
    has :parent_id, :model_id, :location_id, :owner_id, :inventory_pool_id, :supplier_id
# OPTIMIZE
    # this will also exclude items that are reserved for future hand over
    # - i.e. contract_lines that only start in the future and allready have
    #   an item assigned
    has "items.id NOT IN " \
          "(SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL) " \
        "AND parent_id IS NULL",
        :as => :in_stock, :type => :boolean
#    has "items.id IN (SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL)", :as => :not_in_stock, :type => :boolean
    # 0501
    has "retired IS NOT NULL", :as => :retired, :type => :boolean
    has model(:is_package), :as => :model_is_package, :type => :boolean
    
    # set_property :order => :model_name
    set_property :delta => true
  end
  
#temp#
#  define_index "retired_item" do
#    where "retired IS NOT NULL"
#    ...
#  end

  # TODO 0501 doesn't work!
#  default_sphinx_scope :default_search
#  sphinx_scope(:default_search) { {:with => {:retired => false}} }
  sphinx_scope(:retired) { {:with => {:retired => true}} }

  def touch_for_sphinx
    @block_delta_indexing = true
    save # trigger reindex
  end

  private
  def update_sphinx_index
    return if @block_delta_indexing
    model.touch_for_sphinx
    location.touch_for_sphinx if location
#    Contract.suspended_delta do
#      contracts.each {|x| x.touch_for_sphinx }
#    end
  end
  public

####################################################################
# preventing delete

  def self.delete_all
    false
  end

  before_destroy do
    unless model.is_package?
      errors.add(:base, "Item cannot be deleted")
      return false
    end
  end
    
####################################################################

  default_scope where(:retired => nil)
  #scope :retired, unscoped { where{{retired.not_eq => nil}} } # NOTE using squeel gem # where(arel_table[:retired].not_eq(nil))
  #scope :retired_and_unretired, unscoped {}

####################################################################

  scope :borrowable, where(:is_borrowable => true, :parent_id => nil) 
  scope :unborrowable, where(:is_borrowable => false)

  scope :broken, where(:is_broken => true)
  scope :incomplete, where(:is_incomplete => true)

  scope :unfinished, where(['inventory_code IS NULL OR model_id IS NULL'])
  scope :unallocated, where(['inventory_pool_id IS NULL'])
 
  scope :inventory_relevant, where(:is_inventory_relevant => true)
  scope :not_inventory_relevant, where(:is_inventory_relevant => false)
 
  # OPTIMIZE 1102** use item_lines association
  scope :packages, where(['items.id IN (SELECT DISTINCT parent_id FROM items WHERE retired IS NULL)'])
  #temp# scope :packaged, where("parent_id IS NOT NULL")
  
  # Added parent_id to "in_stock" so items that are in packages are considered to not be available
  scope :in_stock, where(['items.id NOT IN (SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL) AND parent_id IS NULL'])
  scope :not_in_stock, where(['items.id IN (SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL)'])

####################################################################

  def to_s
    "#{model.name} #{inventory_code}"
  end
 
  # Returns an array of field headers for CSV, useful for including as first line
  # using e.g. FasterCSV. Matches what's returned by to_csv_array
  def self.csv_header    
    ['inventory_code', 
      'inventory_pool',
      'owner',
      'serial_number',
      'model_name', 
      'borrowable',
      'categories',
      'invoice_number',
      'invoice_date',
      'last_check',
      'retired',
      'retired_reason',
      'price',
      'current_borrowing_information',
      'is_broken',
      'is_incomplete',
      'is_borrowable',
      'part_of_package',
      'created_at',
      'updated_at',
      'needs_permission',
      'is_inventory_relevant',
      'responsible',
      'supplier',
      'model_manufacturer']
  end

  # Generates an array suitable for outputting a line of CSV using FasterCSV
  def to_csv_array    
    if self.inventory_pool.nil? or self.inventory_pool.name.blank?
      ip = "UNKNOWN"
    else
      ip = self.inventory_pool.name 
    end

    if self.model.nil? or self.model.name.blank?
      model_name = "UNKNOWN/CHANGED"
      model_manufacturer = "UNKNOWN" if self.model.manufacturer.blank?
    else
      model_name = self.model.name.gsub(/\"/, '""')
      model_manufacturer = self.model.manufacturer.gsub(/\"/, '""') unless self.model.manufacturer.blank?
    end

    if self.owner.nil? or self.owner.name.blank?
      owner = "UNKNOWN"
    else
      owner = self.owner.name
    end

    unless self.model.categories.nil? or self.model.categories.count == 0
      categories = []
      self.model.categories.each do |c|
        categories << c.name + "|"
      end
    end
    
    if self.supplier.blank?
      supplier = "UNKNOWN"
    else
      supplier = self.supplier.name
    end
    
    if self.parent
      part_of_package = "#{self.parent.id} #{self.parent.model.name}"
    else
      part_of_package = "NONE"
    end
   
    # Using #{} notation to catch nils gracefully and silently 
    return [ self.inventory_code,
      ip,  
      owner,
      "#{self.serial_number}",
      model_name,
      "#{self.is_borrowable}",
      categories,
      "#{self.invoice_number}",
      "#{self.invoice_date}",
      "#{self.last_check}",
      "#{self.retired}",
      "#{self.retired_reason}",
      "#{self.price}",
      "#{self.current_borrowing_info}",
      "#{self.is_broken}",
      "#{self.is_incomplete}",
      "#{self.is_borrowable}",
      part_of_package,
      "#{self.created_at}",
      "#{self.updated_at}",
      "#{self.needs_permission}",
      "#{self.is_inventory_relevant}",
      "#{self.responsible}",
      supplier,
      model_manufacturer
    ]
    
  end
   
  
  def inventory_code
    s = read_attribute('inventory_code')
    s = "#{parent.inventory_code}/#{s}" if parent
    s
  end
  
  def inv_code_with_location
    "#{inventory_code}<br/><div>#{location}</div>"
  end

####################################################################

  # extract *last* number sequence in string   
  def self.last_number(inventory_code)
    inventory_code ||= ""
    inventory_code.reverse.sub(/[^\d]*/,'').sub(/[^\d]+.*/,'').reverse.to_i
  end

  # proposes the next available number based on the owner inventory_pool
  # tries to take the next free inventory code after the previously created Item
  def self.proposed_inventory_code(inventory_pool)
    last_inventory_code = Item.unscoped { Item.where(:owner_id => inventory_pool).order("created_at DESC").first.try(:inventory_code) }
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
    allocated_inventory_code_numbers(true).delete_if {|k, v| not v.is_a? Array }
  end

  # returns [ [1, 2], [5, 23], [28, 29], ... [9990, Infinity] ]
  # all displayed numbers [from, to] included are available 
  #
  # Attention: params could be negative!
  #
  def self.free_inventory_code_ranges(params)
    infinity = 1/0.0
    default_params = { :from => 1, :to => infinity, :min_gap => 1 }
    params.reverse_merge!(default_params)

    from = [ params[:from].to_i, 1 ].max
    if params[:to] == infinity
      to = infinity
    else
      to = [[params[:to].to_i, from].max, infinity].min
    end
    min_gap = [[params[:min_gap].to_i, 1].max, to].min

    ranges = []
    last_n = from-1

    sorted_numbers = allocated_inventory_code_numbers.keys.select {|n| n >= from and n <= to}.sort
    sorted_numbers.each do |n|
      ranges << [last_n+1, n-1] if n-1 != last_n and (n-1 - last_n >= min_gap)
      last_n = n
    end
    ranges << [last_n+1, to] if last_n+1 <= to and (to - last_n >= min_gap)
  
    ranges
  end

####################################################################

  # an item is in stock if it's not handed over
  def in_stock?
    if parent_id
      parent.in_stock?
    else    
      contract_lines.to_take_back.empty?
    end
  end


####################################################################

  def current_borrowing_info
    # TODO 1102** make sure is only max 1 contract_line
    contract_line = contract_lines.where(:returned_date => nil).first
    
    # FIXME this is a quick fix
    if contract_line
      _("%s until %s") % [contract_line.contract.user, contract_line.end_date.strftime("%d.%m.%Y")] # TODO 1102** patch Date.to_s => to_s(:rfc822)
    end
  end

####################################################################

  def log_history(text, user_id)
    h = histories.create(:text => text, :user_id => user_id, :type_const => History::BROKEN)
    histories.reset if h.changed?
  end
  
  
####################################################################

  def update_children_attributes
    Item.suspended_delta do
      children.each do |child|
        update_child_attributes(child)
      end
    end unless children.empty?
  end

####################################################################

  private
  
  def validates_package
    if parent_id
      if parent.nil?
        errors.add(:base, _("The parent item doesn't exist (parent_id: %d)") % parent_id)
      elsif not children.empty?
        errors.add(:base, _("A package cannot be nested to another package"))
      else
        errors.add(:inventory_pool_id, _("doesn‘t match parent's attribute")) unless inventory_pool_id == parent.inventory_pool_id
        errors.add(:location_id, _("doesn‘t match parent's attribute")) unless location_id == parent.location_id
        errors.add(:responsible, _("doesn‘t match parent's attribute")) unless responsible == parent.responsible
      end
    else
      errors.add(:base, _("Package error")) unless children.empty? or model.is_package
    end
  end
  
  def validates_model_change
    errors.add(:base, _("The model cannot be changed because the item is used in contracts already.")) if model_id_changed? and not contract_lines.empty? 
  end

  def validates_retired
    errors.add(:base, _("The item cannot be retired because it's not returned yet.")) if not retired.nil? and not in_stock? 
  end

  def update_child_attributes(item)
    item.update_attributes(:inventory_pool_id => self.inventory_pool_id,
                           :location_id => self.location_id,
                           :responsible => self.responsible)
  end

end

