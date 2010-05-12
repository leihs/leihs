Given "a $role for inventory pool '$ip_name' logs in as '$who'" do | role, ip_name, who |
  Given "inventory pool '#{ip_name}'"
  user = Factory.create_user({:login => who
                                #, :password => "pass"
                              },
			      {:role => role,
			       :inventory_pool => @inventory_pool })
  post "/session", :login => user.login
                      #, :password => "pass"
  get backend_inventory_pool_path(@inventory_pool, :locale => 'en_US')
  @inventory_pool = assigns(:current_inventory_pool)
  @last_manager_login_name = who
  @last_user = user
end
