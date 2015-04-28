FactoryGirl.define do

  factory :template do
    name { Faker::Name.name }
    type { 'Template' }
  end
end