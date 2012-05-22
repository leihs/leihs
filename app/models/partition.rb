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
      # TODO: we're breaking the separation of concerns principle here:
      #       availablity concerns should be exclusively dealt with inside
      #       models/availabilit/* 
      @model.delete_availability_changes_in(@inventory_pool)
    end
  
    # returns a hash {nil => 10, 41 => 3, 42 => 6, ...}
    def current_partition
      r = {Group::GENERAL_GROUP_ID => by_group(Group::GENERAL_GROUP_ID)} # this are available for general group
      @partitions.each {|p| r[p.group_id] = p.quantity } # these are the partitions defined by the inventory manager
      r
    end
          
    def by_group(group, with_update = true)
      if group.nil?
        #tmp#1402 @inventory_pool.items.borrowable.scoped_by_model_id(@model).count - sum(:quantity)
        quantity = @inventory_pool.items.borrowable.where(:model_id => @model).count - @partitions.sum(:quantity, :conditions => "group_id IS NOT NULL")
        return quantity unless with_update
        p = @partitions.where(:group_id => Group::GENERAL_GROUP_ID).first
        if quantity > 0
          if p
            p.update_attributes(:quantity => quantity) if quantity != p.quantity
          else
            @partitions.create(:group_id => Group::GENERAL_GROUP_ID, :quantity => quantity)
          end
        elsif p
          p.destroy
        end
        quantity # TODO return p ??
      else
        @partitions.scoped_by_group_id(group).first
      end
    end
       
    def by_groups(groups)
      @partitions.where(:group_id => groups)
    end
    
    def all
      @partitions
    end
  end
end
