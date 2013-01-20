module Json
  module UserHelper

    def hash_for_user(user, with = nil)
      h = {
         type: 'user',
         id: user.id,
         name: user.to_s,
         firstname: user.firstname,
         lastname: user.lastname
      }
      
      if with ||= nil
        [:image_url, :email, :address, :zip, :city, :phone, :badge_id].each do |k|
          h[k] = user.send(k) if with[k]
        end
        
        if with[:groups]
          h[:groups] = user.groups.as_json # TODO
        end

        if with[:access_right] and current_inventory_pool and access_right = user.access_rights.where(:inventory_pool_id => current_inventory_pool.id).first
          h[:access_right] = hash_for(access_right, with[:access_right])
        end

      end
      
      h
    end
  end
end
      