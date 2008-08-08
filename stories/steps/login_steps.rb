steps_for(:login) do

  Given "an $role for inventory pool '$ip' logs in as '$who'" do | role, ip, who |
    user = Factory.create_user({:login => who
                                  #, :password => "pass"
                                }, {:role => role})
    post "/session", :login => user.login
                        #, :password => "pass"
    inventory_pool = InventoryPool.find_or_create_by_name(:name => ip)
    get "/backend/dashboard/switch_inventory_pool/#{inventory_pool.id}"
  end

end