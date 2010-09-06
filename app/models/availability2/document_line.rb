module Availability2
  module DocumentLine
    
    # TODO cache ??
    def available?
      Availability2::Change.overbooking_for_model(model, inventory_pool).detect {|o| o[:start_date] <= end_date and o[:end_date] >= start_date }.nil?
    end

    class Observer < ActiveRecord::Observer
      observe :order_line, :contract_line
      
      def recompute
        if (record.is_a?(OrderLine) and record.order.status_const == Order::SUBMITTED) or record.is_a?(ContractLine)
          Availability2::Change.recompute(record.model, record.document.inventory_pool)
        end
      end
      
      def after_save(record)
        recompute
      end

      def after_destroy(record)
        recompute
      end
    end

  end

end