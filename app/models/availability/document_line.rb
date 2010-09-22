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
      # TODO ??
      #if is_late?
      #  false

      #tmp#1 doesn't work for tests
      if end_date < Date.today # check if it was never handed over
        false
      elsif is_a?(OrderLine) and order.status_const == Order::UNSUBMITTED
        # the user's unsubmitted order_lines should exclude each other
        all_quantities = model.order_lines.scoped_by_inventory_pool_id(inventory_pool).unsubmitted.running(start_date).by_user(order.user).sum(:quantity)
        (maximum_available_quantity >= all_quantities)
      else
        #tmp#5 use :availability_quantities through association
        availability_out_document_lines.count(:joins => :quantity, :conditions => "availability_quantities.in_quantity < 0").zero?
      end
    end

    def allocated_group
      availability_out_document_lines.first.try(:quantity).try(:group)
    end

    def unavailable_periods
      #tmp#4 TODO check if I'm already allocated to a Group (non-General)
      
      changes = Availability::Change.overbooking(inventory_pool, model)
      changes.collect do |c|
        OpenStruct.new(:start_date => c.start_date, :end_date => c.end_date)
      end
    end

    # this is only used for unsubmitted OrderLines
    def maximum_available_quantity
      Availability::Change.maximum_available_in_period_for_user(model, inventory_pool, document.user, start_date, end_date)      
    end

  end
end