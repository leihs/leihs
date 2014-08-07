FactoryGirl.define do

  trait :shared_attachment_attributes do
    filename { Faker::Lorem.word }
    content_type "image/jpeg"
    base64_string { Base64.encode64 File.open("features/data/images/image1.jpg").read }
  end

  factory :attachment do
    shared_attachment_attributes
  end

  factory :image do
    shared_attachment_attributes

    trait :another do
      base64_string { Base64.encode64 File.open("features/data/images/image2.jpg").read }
    end
  end
end
