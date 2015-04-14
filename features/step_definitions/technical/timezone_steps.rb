When(/^leihs' time zone is set to "(.*?)"$/) do |tz|
  expect(@setting.update_attributes({:time_zone => tz})).to be true
end

Then(/^ActiveSupport thinks the time zone is "(.*?)"$/) do |tz|
  Rails.configuration.time_zone = tz
end

When(/^a record with created_at is created$/) do
  @record = FactoryGirl.create(:user)
end

Then(/^that record's created_at is in the "(.*?)" time zone( when using in_time_zone)?$/) do |tz, arg1|
  dt = if arg1
         @record.created_at.in_time_zone
       else
         @record.created_at
       end
  expect(dt.time_zone.to_s).to eq tz
end

Then(/^Time\.zone is "(.*?)"$/) do |tz|
  expect(Time.zone.to_s).to eq tz
end


