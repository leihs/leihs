module Availability

    class Observer < ActiveRecord::Observer
      observe :order_line, :item_line, :item
      
      #tmp#3 TODO bulk recompute if many lines are updated together
      
      def recompute(record)
        debugger
        if record.is_a?(Item) and record.inventory_pool
            Availability::Change.recompute(record.model, record.inventory_pool)
        elsif (record.is_a?(OrderLine) and record.order.status_const == Order::SUBMITTED) or record.is_a?(ItemLine)
          puts record.inspect, "--------------"
            Availability::Change.recompute(record.model, record.document.inventory_pool) unless record.model_id.nil?
        end
      end
      
      def after_save(record)
        recompute(record)
      end

      def after_destroy(record)
        recompute(record)
      end
    end

end