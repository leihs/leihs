# An Item an instance of a #Model, has its own barcode
# and thus its own identity and is potentially borrowable
#
class Item < ActiveRecord::Base
  
  belongs_to :parent, :class_name => "Item", :foreign_key => 'parent_id'
  has_many :children, :class_name => "Item", :foreign_key => 'parent_id', :dependent => :nullify
  
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
  validate :validates_if_is_package, :validates_model_change

####################################################################

  before_save do |record|
    record.owner = record.inventory_pool if record.inventory_pool and !record.owner
  end

  after_save :update_index

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
    has "items.id NOT IN (SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL) AND parent_id IS NULL", :as => :in_stock, :type => :boolean
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

####################################################################
# preventing delete

  def self.delete_all
    false
  end

  def before_destroy
    unless model.is_package?
      errors.add_to_base "Item cannot be deleted"
      return false
    end
  end
    
####################################################################
# OPTIMIZE retired filter, default_scope

  def self.find(*args)
    retired = args.last.delete(:retired) if args.last.is_a?(Hash)
    # OPTIMIZE in case of Ferret rebuild_index, reindex all items, 1000 is the limit default used by ferret
    retired ||= :all if args.last.is_a?(Hash) and args.last[:limit] == 1000
    if retired == :all
      super(*args)  
    else
      with_scope( :find => { :conditions=> "#{class_name.downcase.pluralize}.retired IS #{retired ? "NOT" : ""} NULL" }) do
        super(*args)
      end
    end
  end

  def self.count(*args)
    retired = args.last.delete(:retired) if args.last.is_a?(Hash)
    if retired == :all
      super(*args)  
    else
      with_scope( :find => { :conditions=> "#{class_name.downcase.pluralize}.retired IS #{retired ? "NOT" : ""} NULL" }) do
        super(*args)
      end
    end
  end

# TODO 0501
#  default_scope :conditions => {:retired => nil}
#  named_scope :retired, :conditions => "retired IS NOT NULL"

####################################################################

  named_scope :borrowable, :conditions => {:is_borrowable => true, :parent_id => nil} 
  named_scope :unborrowable, :conditions => {:is_borrowable => false}

  named_scope :broken, :conditions => {:is_broken => true}
  named_scope :incomplete, :conditions => {:is_incomplete => true}

  named_scope :unfinished, :conditions => ['inventory_code IS NULL OR model_id IS NULL']
  named_scope :unallocated, :conditions => ['inventory_pool_id IS NULL']
 
  named_scope :inventory_relevant, :conditions => {:is_inventory_relevant => true}
  named_scope :not_inventory_relevant, :conditions => {:is_inventory_relevant => false}
 
  # OPTIMIZE 1102** use item_lines association
  named_scope :packages, :conditions => ['items.id IN (SELECT DISTINCT parent_id FROM items WHERE retired IS NULL)']
  #temp# named_scope :packaged, :conditions => "parent_id IS NOT NULL"
  
  # Added parent_id to "in_stock" so items that are in packages are considered to not be available
  named_scope :in_stock, :conditions => ['items.id NOT IN (SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL) AND parent_id IS NULL']
  named_scope :not_in_stock, :conditions => ['items.id IN (SELECT item_id FROM contract_lines WHERE item_id IS NOT NULL AND returned_date IS NULL)']

####################################################################

  def to_s
    "#{model.name} #{inventory_code}"
  end
  
  def inventory_code
    s = read_attribute('inventory_code')
    s = "#{parent.inventory_code}/#{s}" if parent
    s
  end
  
  def inv_code_with_location
    "#{inventory_code}<br/><div>#{location}</div>"
  end

  def self.proposed_inventory_code
    last = 0
    all.collect(&:inventory_code).each do |x| i = x.gsub(/[^\d]/, "").to_i
      #TODO More generic so non-ZHdK users don't get brain explosions
      last = i if i > last and i < 100000
    end
    last + 1
  end
    
  # TODO remove this method when no more needed (it is used for Rspec tests)
  # generates a new and unique inventory code
  def self.get_new_unique_inventory_code
    begin
      chars_len = 1
      nums_len = 2
      chars = ("A".."Z").to_a
      nums = ("0".."9").to_a
      code = ""
      1.upto(chars_len) { |i| code << chars[rand(chars.size-1)] }
      1.upto(nums_len) { |i| code << nums[rand(nums.size-1)] }
    end while exists?(:inventory_code => code)
    code
  end

  # OPTIMIZE 0501 performance: named_scope or sphinx_scope in_stock?(self)
  def in_stock?(contract_line_id = nil)
    if contract_line_id
      return contract_lines.to_take_back.count(:conditions => ["contract_lines.id != ?", contract_line_id]) == 0
    else
      return contract_lines.to_take_back.empty?
    end
  end

  def borrowable_by?(user)
    user.level_for(inventory_pool) >= required_level
  end

####################################################################

  def current_borrowing_info
    # TODO 1102** make sure is only max 1 contract_line
    contract_line = contract_lines.first(:conditions => {:returned_date => nil})
    _("%s until %s") % [contract_line.contract.user, contract_line.end_date.strftime("%d.%m.%Y")] # TODO 1102** patch Date.to_s => to_s(:rfc822)
  end

####################################################################

  def log_history(text, user_id)
    h = histories.create(:text => text, :user_id => user_id, :type_const => History::BROKEN)
    histories.reset if h.changed?
  end
  
  
####################################################################

  private
  
  def validates_if_is_package
    errors.add_to_base(_("Package error")) if children.size > 0 and !model.is_package
  end
  
  def validates_model_change
    errors.add_to_base(_("The model cannot be changed because the item is used in contracts already.")) if model_id_changed? and not contract_lines.empty? 
  end

  def update_index
    model.touch
    location.touch if location
#    Contract.suspended_delta do
#      contracts.each {|x| x.touch }
#    end
  end

end
