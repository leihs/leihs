module Availability
  module DocumentLine

    def self.included(base)
      base.has_many :availability_out_document_lines,
                    :as => :document_line,
                    :class_name => "Availability::OutDocumentLine"
#tmp#5
#      base.has_many :availability_quantities,
#                    :through => :availability_out_document_lines,
#                    :source => :quantity,
#                    :source_type => "ContractLine", #'#{self.class.to_s}',
#                    :class_name => "Availability::Quantity"
    end

    # if overdue, extend end_date to today
    def availability_end_date
      d = if is_a?(ContractLine) and returned_date
            returned_date
          elsif is_late?
            # TODO stammtisch
            #Availability::ETERNITY
            Date.today + Availability::REPLACEMENT_INTERVAL
          else
            end_date
          end
      d + model.maintenance_period.day
    end

    def available_again_date
      availability_end_date.tomorrow
    end

#################################
    
    def available?
      # TODO is_late?

#      if end_date < Date.today # check if it was never handed over
#        false
#      elsif is_allocated_to_general_group?
#        Availability::Change.overbooking(inventory_pool, model).between(start_date, end_date).empty? # TODO  availability_end_date
#      else
#        true # TODO this is now wrong, because overdue document_lines, even groups could be negative
#      end

      #tmp#5 use :availability_quantities through association
      
      if end_date < Date.today # check if it was never handed over
        false
      else
        availability_out_document_lines.count(:joins => :quantity, :conditions => "availability_quantities.in_quantity < 0").zero?
      end
    end

#tmp#5
#    def is_allocated_to_general_group?
#      start_change = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).first(:conditions => {:date => start_date})
#      out_document_lines = start_change.quantities.general.out_document_lines
#      if out_document_lines
#        out_document_lines.include?({:type => self.class.to_s, :id => id}) #tmp#5
#      else
#        false
#      end
#    end

# TODO
#    def allocated_group
#    end

    def unavailable_periods
      #tmp#4 TODO check if I'm already allocated to a Group (non-General)
      
      changes = Availability::Change.overbooking(inventory_pool, model)
      changes.collect do |c|
        { :start_date => c.start_date,
          :end_date => c.end_date }
      end
    end

  end
end