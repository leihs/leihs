FactoryGirl.define do

  factory :attachment do

    filename { Faker::Lorem.word }
    content_type "image/jpeg"
    base64_string { Base64.encode64 File.open("features/data/images/image1.jpg").read }
  end
end
