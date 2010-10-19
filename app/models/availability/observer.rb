module Availability

    class Observer < ActiveRecord::Observer
      observe :order_line, :item_line, :item
      
      #tmp#6 OPTIMIZE bulk recompute if many lines are updated together
      
      def recompute(record)
        if record.is_a?(Item) and record.inventory_pool
          record.model.availability_changes.in(record.inventory_pool).recompute
        elsif (record.is_a?(OrderLine) and record.order.status_const == Order::SUBMITTED) or record.is_a?(ItemLine)
          record.recompute
        end
      end
      
      def after_save(record)
        # in case only unrelevant attributes are changed, we don't want to recompute
        return if record.is_a?(Item) and (record.changed - ["delta", "updated_at"]).empty? 
        recompute(record)
      end

      def after_destroy(record)
        recompute(record)
      end
    end
end
