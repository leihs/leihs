class Partition < ActiveRecord::Base
  acts_as_audited :associated_with => :model
  
  belongs_to :model
  belongs_to :inventory_pool
  belongs_to :group
  
  validates_presence_of :model, :inventory_pool, :quantity
  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0
  
  # TODO when leihs2 is switched off: remove this default_condition and validates presence of :group
  default_scope :conditions => "group_id IS NOT NULL"
  
  # also see model.rb->def in(...).
  # Model extends the "partitions" relation at access time with further methods

  class Scoped
    
    def initialize(inventory_pool, model, partitions)
      @inventory_pool = inventory_pool
      @model = model
      @partitions = partitions
    end
  
    def set(new_partitions)
      @partitions.delete_all
      new_partitions.delete(Group::GENERAL_GROUP_ID)
      unless new_partitions.blank?
        valid_group_ids = @inventory_pool.group_ids
        new_partitions.each_pair do |group_id, quantity|
          group_id = group_id.to_i
          quantity = quantity.to_i
          @partitions.create(:group_id => group_id, :quantity => quantity) if valid_group_ids.include?(group_id) and quantity > 0
        end
      end
      # if there's no more items of a model in a group accessible to the customer,
      # then he shouldn't be able to see the model in the frontend.
    end
             
    def all
      @partitions
    end
  end
end
