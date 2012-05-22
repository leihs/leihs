module Statistics

  class Base
  
    class << self
  
      # Who borrowed the most things?
      def most_borrower(date_range = nil)
        #Contract.signed_or_closed.select("user_id, count(*) as c").group_by(&:user_id).order_by("c desc").first
        Contract.signed_or_closed.group_by(&:user_id).first.first
      end
  
      # Which inventory pool is busiest?
      def busiest_inventory_pool
        Contract.signed_or_closed.group_by(&:inventory_pool_id).first.first
      end
      
      # Who bought the most items?
      def most_items_inventory_pool
        Item.all.group_by(&:inventory_pool_id).first.first
      end
      
      # Which inventory pool costs the most money?
      def most_money_inventory_pool
        nil
      end
      
    end
  
  end
end
