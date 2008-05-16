class Item < ActiveRecord::Base
  
  AVAILABLE = 1
  IN_REPAIR = 2
  
  belongs_to :model
  belongs_to :inventory_pool
  has_many :contract_lines

  validates_uniqueness_of :inventory_code

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
  
end
