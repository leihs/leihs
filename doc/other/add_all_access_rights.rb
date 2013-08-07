

def add_all_access_rights(user)
  InventoryPool.all.each do |ip|
    ars = user.access_rights.find(:all, :conditions => {:inventory_pool_id => ip.id,
                                                        :role_id => 4})
    if ars.empty?
      user.access_rights.create(:inventory_pool_id => ip.id,
                                :role_id => 4)
    else

  end
end