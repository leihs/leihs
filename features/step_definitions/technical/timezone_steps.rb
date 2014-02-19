When(/^leihs' time zone is set to "(.*?)"$/) do |tz|
  @setting.update_attributes({:time_zone => tz}).should be_true
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

Then(/^that record's created_at is in the "(.*?)" time zone when using in_time_zone$/) do |tz|
  @record.created_at.in_time_zone.time_zone.to_s.should == tz
end

Then(/^Time\.zone is "(.*?)"$/) do |tz|
  Time.zone.to_s.should == tz
end


