FactoryGirl.define do

  factory :access_right do
    role_id {rand(Role.all.count-1)}
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