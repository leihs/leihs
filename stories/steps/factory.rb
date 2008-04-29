module Factory
  
  def self.create_user(attributes = {})
    default_attributes = {
      :login => "jerome",
      :email  => "jerome@example.com",
    }
    u = User.create default_attributes.merge(attributes)
    u.save
    u
  end
  
  def self.create_order(attributes = {}, options = {})
    default_attributes = {

    }
    o = Order.create default_attributes.merge(attributes)
    options[:order_lines].times { |i|
        model = Factory.create_model(:name => "model_#{i}" )
        d = Array.new
        2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
        o.add_line(rand(3), model, o.user_id, d.min, d.max )
    } if options[:order_lines]
    o.save
    o
  end
  
  def self.create_model(attributes = {})
    default_attributes = {
      :name => 'model_1'
    }
    t = Model.create default_attributes.merge(attributes)
    t.save
    t
  end

  def self.create_item(attributes = {})
    default_attributes = {
      :inventory_code => "1"
      
    }
    
    i = Item.create default_attributes.merge(attributes)
    i.save
    i
  end
  
  def self.parsedate(str)
    match = /(\d{1,2})\.(\d{1,2})\.(\d{2,4})\.?/.match(str)
    unless match
      ret = ParseDate.old_parsedate(str)
    else
      ret = [match[3].to_i, match[2].to_i, match[1].to_i, nil, nil, nil, nil, nil] 
    end
    DateTime.new(ret[0], ret[1], ret[2])
  end

#  def self.create_order_line(attributes = {})
#      model = Factory.create_model
#
#      d = Array.new
#      2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
#      
#      ol = OrderLine.new(:quantity => rand(3),
#                         :model_id => model.to_i,
#                         :start_date => d.min,
#                         :end_date => d.max)
#      ol              
#  end
  
end