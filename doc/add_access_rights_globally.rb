def add_access_right(user, inventory_pool, role = :customer)

  existing = user.access_rights.where(inventory_pool_id: inventory_pool, role: role).first
  if existing
    return true
  else
    new_right = user.access_rights.build(inventory_pool: inventory_pool, role: role)
    if new_right.save
      return true
    else
      puts new_right.errors.full_messages
      return false
    end
  end

end
