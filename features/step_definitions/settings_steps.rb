Given(/^the settings are exising$/) do
  FactoryGirl.create :setting unless Setting.first
end

When(/^the settings are not exising$/) do
  Setting.delete_all
  Setting.count.should be_zero
  Setting.send :remove_const, "SMTP_ADDRESS"
  Setting.const_defined?("SMTP_ADDRESS").should be_false
end

Then(/^there is an error for the missing settings$/) do
  lambda { step "I go to the home page" }.should raise_error(RuntimeError)
end

Then(/^I can edit the following settings$/) do |table|
  pending
  first("form[action='/backend/settings']")
  @old_setting_smtp_address = first("input#setting_smtp_address").value
  Setting::SMTP_ADDRESS.should == @old_setting_smtp_address
end

Then(/^the settings are persisted$/) do
  new_setting_smtp_address = Faker::Internet.domain_name
  new_setting_smtp_address.should_not == @old_setting_smtp_address
  step 'I fill in "setting_smtp_address" with "%s"' % new_setting_smtp_address
  first("button.green[type='submit']").click
  Setting::SMTP_ADDRESS.should == new_setting_smtp_address
  Setting.first.smtp_address.should == new_setting_smtp_address
end
