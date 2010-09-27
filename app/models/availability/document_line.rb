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

    def recompute
      if (old_model = availability_out_document_lines.first.try(:quantity).try(:change).try(:model)) and old_model != model
        old_model.availability_changes.in(document.inventory_pool).recompute
      end
      model.availability_changes.in(document.inventory_pool).recompute
    end

    # if overdue, extend end_date to today
    def availability_end_date
      d = if is_a?(ContractLine) and returned_date
            returned_date
          elsif is_late?
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
      group = allocated_group
      
      conditions = ["group_id " + (group.nil? ? "IS NULL" : "= #{group.id}")]
      conditions[0] += " AND ((in_quantity < 0 AND date BETWEEN :sd AND :ed) OR (in_quantity < :q AND date NOT BETWEEN :sd AND :ed))"
      conditions << {:q => quantity, :sd => start_date, :ed => end_date}
      
      changes = model.availability_changes.in(inventory_pool).all(:joins => :quantities, :conditions => conditions)
      changes.collect do |c|
        OpenStruct.new(:start_date => c.start_date, :end_date => c.end_date)
      end
    end

    # this is only used for unsubmitted OrderLines
    def maximum_available_quantity
      model.availability_changes.in(inventory_pool).maximum_available_in_period_for_user(document.user, start_date, end_date)      
    end

  end
end