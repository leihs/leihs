class Item < ActiveRecord::Base
  
  BORROWABLE = 1
  UNBORROWABLE = 2
  
  attr_accessor :step
  
  belongs_to :parent, :class_name => "Item", :foreign_key => 'parent_id'
  has_many :children, :class_name => "Item", :foreign_key => 'parent_id'
  
  belongs_to :model
  belongs_to :location
  delegate :inventory_pool, :to => :location  #old# has_one :inventory_pool, :through => :location
  
  has_many :contract_lines
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  validates_uniqueness_of :inventory_code
  #validates_length_of :inventory_code, :minimum => 1, :too_short => "please enter at least %d character", :if => Proc.new {|i| i.step == 'step_item'}
  validates_presence_of :inventory_code, :if => Proc.new {|i| i.step == 'step_item'}
  validates_presence_of :model, :if => Proc.new {|i| i.step == 'step_model'}
  validates_presence_of :location, :if => Proc.new {|i| i.step == 'step_location'}
  
  acts_as_ferret :fields => [ :model_name, :inventory_pool_name, :inventory_code, :serial_number ] #, :store_class_name => true

####################################################################

  named_scope :available, :conditions => {:status_const => Item::BORROWABLE} # TODO ['parent_id IS NULL'] 
  named_scope :in_repair, :conditions => {:status_const => Item::UNBORROWABLE}
  named_scope :incompletes, :conditions => ['inventory_code IS NULL OR model_id IS NULL OR location_id IS NULL']
  
  # TODO do we need it?
  named_scope :package_roots, :select => "DISTINCT items.*",
                              :joins => "JOIN items i ON items.id = i.parent_id",
                              :conditions => ['items.parent_id IS NULL']
  
####################################################################

  def to_s
    "#{model.name if model} #{inventory_code}" # TODO remove 'if model'
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

  def in_stock?(contract_line_id = nil)
    if contract_line_id
      return !ContractLine.exists?(["id != ? AND item_id = ? AND returned_date IS NULL", contract_line_id, id])
    else
      return !ContractLine.exists?(["item_id = ? AND returned_date IS NULL", id])
    end
  end

  def is_package?
    children.size > 0
  end

  #######################
  #
  def log_history(text, user_id)
    histories.create(:text => text, :user_id => user_id, :type_const => History::BROKEN)
  end

    # TODO item returns to available
  #
  #######################
  
  
####################################################################

  private
  
  def model_name
    model.name
  end
  
  def inventory_pool_name
    inventory_pool.name
  end  
    
end
