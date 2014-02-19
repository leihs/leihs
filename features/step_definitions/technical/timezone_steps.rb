When(/^leihs' time zone is set to "(.*?)"$/) do |tz|
  Setting::TIME_ZONE = tz
end

Then(/^ActiveSupport thinks the time zone is "(.*?)"$/) do |tz|
  Rails.configuration.time_zone = tz
end

When(/^a record with created_at is created$/) do
  @record = FactoryGirl.create(:user)
end

Then(/^that record's created_at is in the "(.*?)" time zone$/) do |tz|
  @record.created_at.time_zone.to_s.should == tz
end

