class Item < ActiveRecord::Base
  
  BORROWABLE = 1
  UNBORROWABLE = 2
  
  belongs_to :model
  belongs_to :location
  delegate :inventory_pool, :to => :location  #old# has_one :inventory_pool, :through => :location
  
  has_many :contract_lines
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  validates_uniqueness_of :inventory_code
  
  acts_as_ferret :fields => [ :model_name, :inventory_pool_name, :inventory_code, :serial_number ] #, :store_class_name => true

####################################################################

  named_scope :available, :conditions => {:status_const => Item::BORROWABLE} 
  named_scope :in_repair, :conditions => {:status_const => Item::UNBORROWABLE} 

####################################################################

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

  #######################
  #
  def log_history(text, user_id)
    histories << History.new(:text => text, :user_id => user_id, :type_const => History::BROKEN)
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
