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
  
    # returns a hash {nil => 10, 41 => 3, 42 => 6, ...}
    def current_partition
=begin #old# storing the general group partition record to the database      
      pp = @partitions.partition {|x| x.group_id == Group::GENERAL_GROUP_ID } # separate general group from other groups
      general_partition = pp.first.first # the partition for general group, if persisted
      defined_partitions = pp.last # these are the partitions defined by the inventory manager
      
      h = Hash[defined_partitions.map {|p| [p.group_id, p.quantity] }]
      
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
=end

      #new# get the general group on the fly
      h = Hash[by_groups.map {|p| [p.group_id, p.quantity] }]
      h = {Group::GENERAL_GROUP_ID => 0} if h.empty?

      h
    end
       
    def by_groups(groups = [], with_general = true)
      #old# get the stored general group partition record from the database
      #groups += [Group::GENERAL_GROUP_ID] if with_general 
      #@partitions.where(:group_id => groups)

      #new# compute the general group on the sql-side, no need to store the result anymore
      sql = "SELECT group_id, quantity FROM partitions WHERE group_id IS NOT NULL
              AND model_id = #{@model.id} AND inventory_pool_id = #{@inventory_pool.id}"
      sql += " AND group_id IN (#{groups.map(&:id).join(',')}) " unless groups.blank?
      sql += " UNION
              SELECT NULL as group_id, (COUNT(i.id) - 
                IFNULL((SELECT SUM(quantity) FROM partitions AS p
                WHERE p.group_id IS NOT NULL AND p.model_id = i.model_id AND p.inventory_pool_id = i.inventory_pool_id
                GROUP BY p.inventory_pool_id, p.model_id), 0)) as quantity
              FROM items AS i WHERE i.retired IS NULL AND i.is_borrowable = 1 AND i.parent_id IS NULL
              AND i.model_id = #{@model.id} AND i.inventory_pool_id = #{@inventory_pool.id}
              GROUP BY i.inventory_pool_id, i.model_id" if with_general
      Partition.find_by_sql(sql)
    end
    
    def all
      @partitions
    end
  end
end
