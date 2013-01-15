module Json
  module AccessRightHelper

    def hash_for_access_right(access_right, with = nil)
      h = {
          id: access_right.id
      }

      [:access_level, :role_id, :suspended_until, :suspended_reason].each do |k|
        h[k] = access_right.send(k)
      end

      h
    end
  end
end
