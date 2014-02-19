When(/^the mail delivery method is set to "(.*?)"$/) do |method|
  @setting.update_attributes({:mail_delivery_method => method}).should be_true
  Setting::MAIL_DELIVERY_METHOD.should == method
end

Then(/^ActionMailer's delivery method is "(.*?)"$/) do |method|
  ActionMailer::Base.delivery_method.should == method.to_sym
end

When(/^the SMTP username is set to "(.*?)"$/) do |username|
  @setting.update_attributes({:smtp_username => username}).should be_true
  Setting::SMTP_USERNAME.should == username
end

When(/^the SMTP password is set to "(.*?)"$/) do |password|
  @setting.update_attributes({:smtp_password => password}).should be_true
  Setting::SMTP_PASSWORD.should == password
end

Then(/^ActionMailer's SMTP username is "(.*?)"$/) do |username|
  ActionMailer::Base.smtp_settings['user_name'.to_sym].should == username
end

Then(/^ActionMailer's SMTP password is "(.*?)"$/) do |password|
  ActionMailer::Base.smtp_settings['password'.to_sym].should == password
end

Then(/^ActionMailer's SMTP username is nil$/) do
  ActionMailer::Base.smtp_settings['user_name'.to_sym].should == nil
end

Then(/^ActionMailer's SMTP password is nil$/) do
  ActionMailer::Base.smtp_settings['password'.to_sym].should == nil
end
