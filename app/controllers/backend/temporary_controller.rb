class Backend::TemporaryController < Backend::BackendController

  def index
  end
  
  def create_some
    clean_db_and_index
    
    params[:id] = 3
    params[:name] = "model"
    create_some_inventory

    params[:id] = 5
    params[:name] = "user"
    create_some_users

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
      3.times { order.add_line(rand(3), models[rand(models.size)], order.user_id) }
      order.save
    end
  end
  
  def clean_db_and_index
    Item.delete_all
    Model.delete_all
    Order.delete_all
    User.delete_all
  end


end