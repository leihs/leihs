module Json
  module UserHelper

    def hash_for_user(user, with = nil)
      h = {
         type: 'user',
         id: user.id,
         name: user.to_s,
         firstname: user.firstname,
         lastname: user.lastname,
         suspended: user.suspended_inventory_pools.include?(current_inventory_pool)
      }
      
      if with ||= nil
        [:image_url, :email, :address, :zip, :city, :country, :phone, :badge_id].each do |k|
          h[k] = user.send(k) if with[k]
        end
        
        if with[:groups]
          h[:groups] = user.groups.as_json # TODO
        end

        if with[:access_right] and current_inventory_pool and access_right = user.access_rights.where(:inventory_pool_id => current_inventory_pool.id).first
          h[:access_right] = hash_for(access_right, with[:access_right])
          h[:is_editable] = (user.authentication_system.class_name == "DatabaseAuthentication")
        end

        if with[:is_destroyable]
          h[:is_destroyable] = user.can_destroy?
        end

        if with[:db_auth]
          if db_auth = DatabaseAuthentication.find_by_user_id(user.id)
            h[:db_auth] = {login: db_auth.login}
          end
        end
      end
      
      h
    end
  end
end
      
