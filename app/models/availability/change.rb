module Availability
  
  class Change
    
    ETERNITY = Date.parse("3000-01-01")
    REPLACEMENT_INTERVAL = 1.month #1.year
    
    attr_accessor :date
    attr_accessor :quantities

    def initialize(attr)
      @date = attr[:date]
      @quantities = []
    end
  
  #############################################

#no-cache#
=begin  
    def self.recompute_all
      ::Model.suspended_delta do
        ::InventoryPool.all.each do |inventory_pool|
          inventory_pool.models.each do |model|
            model.delete_availability_changes_in(inventory_pool)
            model.availability_changes_in(inventory_pool)
          end
        end
      end
    end
=end
    
  #############################################

    # compares two objects in order to sort them
    def <=>(other)
      self.date <=> other.date
    end

    def start_date
      date
    end
  
  #############################################
  
    def in_quantity_in_group(group)
      q = quantities.detect {|q| q.group_id == group }
      q.try(:in_quantity).to_i
    end

    def out_quantity_in_group(group)
      q = quantities.detect {|q| q.group_id == group }
      q.try(:out_quantity).to_i
    end

  end

end

