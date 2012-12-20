module Json
  module OrderHelper

    def hash_for_order(order, with = nil)
      h = {
        type: "order",
        id: order.id,
        status_const: order.status_const
      }
      
      if with ||= nil
        [:quantity, :created_at, :updated_at, :inventory_pool_id].each do |k|
          h[k] = order.send(k) if with[k]
        end
        
        if with[:purpose]
          h[:purpose] = order.purpose ? hash_for(order.purpose, with[:purpose]) : nil
        end
      
        if with[:lines]
          lines = order.lines.sort_by {|x| x.model.to_s }
          h[:lines] = hash_for lines, with[:lines]
        end
          
        if with[:user]
          h[:user] = hash_for order.user, with[:user] 
        end
        
      end
      
      h
    end

  end
end
