module Availability
    module Group

      GENERAL_GROUP_ID = nil

      def self.included(base)
  
        base.has_many :availability_quantities, :class_name => "Availability::Quantity"
        base.has_many :availability_changes, :class_name => "Availability::Change",
                                             :through => :availability_quantities,
                                             :source => :change
        base.has_many :models, :through => :availability_changes, :uniq => true
        
        base.after_destroy do |record|
          record.models.each do |model|
            Availability::Change.recompute(model, record.inventory_pool) 
          end      
        end
        
      end

    end
end
