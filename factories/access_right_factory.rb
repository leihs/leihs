FactoryGirl.define do

  factory :access_right do
    role_id {
      if Role.all.count.zero?
        FactoryGirl.create(:role).id
      else
        rand(Role.all.count-1)
      end
    }
    user
    inventory_pool
    access_level {
      if role_id == 3
        rand(3)+1
      else
        nil
      end
    }
  end

end
