def add_access_right(user, inventory_pool, role = nil, level = nil)

  if role == nil
    role = Role.where(:name => 'customer').first
  end

  existing = user.access_rights.where(:inventory_pool_id => inventory_pool,
                                      :role_id => role,
                                      :access_level => level).first
  if existing
    return true
  else
    new_right = user.access_rights.build(:inventory_pool_id => inventory_pool.id,
                                         :role_id => role.id,
                                         :access_level => level)
    if new_right.save
      return true
    else
      puts new_right.errors.full_messages
      return false
    end
  end

end



