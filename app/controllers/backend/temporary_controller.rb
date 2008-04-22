class Backend::TemporaryController < Backend::BackendController

  def index
  end
  
  def create_some
    clean_db_and_index
    
    params[:id] = 3
    params[:name] = "model"
    create_some_inventory
    
    create_meaningful_inventory

    params[:id] = 5
    params[:name] = "user"
    create_some_users
    create_meaningful_users

    params[:id] = 10
    create_some_new_orders

    render :text => "Complete"
  end
  
  def create_some_inventory
    params[:id].to_i.times do |i|
      m = Model.new(:name => params[:name] + " " + i.to_s)
      m.save
      5.times do |serial_nr|
        i = Item.new(:model_id => m.id, :inventory_code => serial_nr)
      
        i.save        
      end
    end
  end

  def create_some_users
    params[:id].to_i.times do |i|
      u = User.new(:login => "#{params[:name]}_#{i}")
      u.save
    end
  end

  def create_some_new_orders
    users = User.find(:all)
    models = Model.find(:all)
    params[:id].to_i.times do |i|
      order = Order.new()
      order.user_id = users[rand(users.size)].id
      3.times {
        d = Array.new
        2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
        start_date = d.min 
        end_date = d.max
        order.add_line(rand(3), models[rand(models.size)], order.user_id, start_date, end_date )
      }
      order.purpose = "This is the purpose: text text and more text, text text and more text, text text and more text, text text and more text."
      order.save
    end
  end
  
    
  def create_meaningful_users
    users = ['Ramon Cahenzli', 'Jerome Müller', 'Franco Sellitto']
    users.each do |u|
      u = User.new(:login => u.to_s)
      u.save
    end
  end
  
  def create_meaningful_inventory
			stuff = ['Beamer NEC LT 245', 'Beamer Davis 1650', 'Kamera Nikon D80', 'Stativ Manfrotto 390', 'Brillenputzuch', 'Laserschwert']

			stuff.each do |st|
        m = Model.new(:name => st )
        m.save
        2.times do |serial_nr|
          i = Item.new(:model_id => m.id, :inventory_code => serial_nr)
      
          i.save        
        end
      end
  end
  
  def create_meaningful_orders
  
  end
    
  def clean_db_and_index
    Item.delete_all
    Model.delete_all
    Order.destroy_all #delete_all
    User.delete_all
  end


end
