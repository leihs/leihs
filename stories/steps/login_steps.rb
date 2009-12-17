steps_for(:login) do

  Given "a $role for inventory pool '$ip' logs in as '$who'" do | role, ip, who |
    user = Factory.create_user({:login => who
                                  #, :password => "pass"
                                }, {:role => role})
    post "/session", :login => user.login
                        #, :password => "pass"
    inventory_pool = InventoryPool.find_or_create_by_name(:name => ip)
    get backend_inventory_pool_path(inventory_pool, :locale => 'en_US')
    @inventory_pool = assigns(:current_inventory_pool)
    @last_lending_manager_login_name = who
  end
  
  Given "User '$name' is a '$level' customer" do |name, level|
    @user = Factory.create_user({:login => name
                                  #, :password => "pass"
                                }, {:role => 'customer'})
    r = @user.access_rights.first
    r.level = AccessRight::LEVELS[level]
    r.save
  end


end