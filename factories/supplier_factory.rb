FactoryGirl.define do
  factory :supplier do
    name {
      begin
        r = Faker::Lorem.words(rand(2..5)).join(' ')
      end while Supplier.find_by_name(r)
      r
    }
  end
end
