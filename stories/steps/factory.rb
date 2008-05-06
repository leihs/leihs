module Factory
  
  def self.create_user(attributes = {})
    default_attributes = {
      :login => "jerome",
      :email  => "jerome@example.com",
    }
    u = User.find_or_create_by_login default_attributes.merge(attributes)
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
    DateTime.new(ret[0], ret[1], ret[2]) # TODO Date
  end

  def self.create_order_line(options = {})
      model = Factory.create_model :name => options[:model_name]

      if options[:start_date]
        start_date = parsedate(options[:start_date])
        end_date = start_date + 2.days
      else
        d = Array.new
        2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
        start_date = d.min
        end_date = d.max
      end
      
      ol = OrderLine.new(:quantity => options[:quantity],
                         :model_id => model.to_i,
                         :start_date => start_date,
                         :end_date => end_date)
      ol              
  end
  
end