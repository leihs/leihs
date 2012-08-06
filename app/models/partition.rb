class Partition < ActiveRecord::Base
  acts_as_audited :associated_with => :model
  
  belongs_to :model
  belongs_to :inventory_pool
  belongs_to :group
  
  validates_presence_of :model, :inventory_pool, :quantity
  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0
  
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
  
    # returns a hash {nil => 10, 41 => 3, 42 => 6, ...}
    def current_partition
      pp = @partitions.partition {|x| x.group_id == Group::GENERAL_GROUP_ID } # separate general group from other groups
      general_partition = pp.first.first # the partition for general group, if persisted
      defined_partitions = pp.last # these are the partitions defined by the inventory manager
      
      h = Hash[defined_partitions.each {|p| [p.group_id, p.quantity] }]
      
      # this are available for general group
      quantity = @inventory_pool.items.borrowable.where(:model_id => @model).count - h.values.sum
      if quantity > 0
        if general_partition
          general_partition.update_attributes(:quantity => quantity) if quantity != general_partition.quantity
        else
          @partitions.create(:group_id => Group::GENERAL_GROUP_ID, :quantity => quantity)
        end
      elsif general_partition
        general_partition.destroy
      end
      h[Group::GENERAL_GROUP_ID] = quantity
      
      h
    end
       
    def by_groups(groups, with_general = true)
      groups += [Group::GENERAL_GROUP_ID] if with_general 
      @partitions.where(:group_id => groups)
    end
    
    def all
      @partitions
    end
  end
end
