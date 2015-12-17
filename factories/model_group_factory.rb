FactoryGirl.define do

  factory :model_group do
    name { Faker::Name.name }
    type { (rand(0..4) == 4) ? 'Template' : 'Categorie' }
  end
end
