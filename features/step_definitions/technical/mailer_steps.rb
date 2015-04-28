When(/^the mail delivery method is set to "(.*?)"$/) do |method|
  expect(@setting.update_attributes({mail_delivery_method: method})).to be true
  expect(Setting::MAIL_DELIVERY_METHOD).to eq method
end

Then(/^ActionMailer's delivery method is "(.*?)"$/) do |method|
  expect(ActionMailer::Base.delivery_method).to eq method.to_sym
end

When(/^the SMTP username is set to "(.*?)"$/) do |username|
  expect(@setting.update_attributes({smtp_username: username})).to be true
  expect(Setting::SMTP_USERNAME).to eq username
end

When(/^the SMTP password is set to "(.*?)"$/) do |password|
  expect(@setting.update_attributes({smtp_password: password})).to be true
  expect(Setting::SMTP_PASSWORD).to eq password
end

Then(/^ActionMailer's SMTP username is "(.*?)"$/) do |username|
  expect(ActionMailer::Base.smtp_settings['user_name'.to_sym]).to eq username
end

Then(/^ActionMailer's SMTP password is "(.*?)"$/) do |password|
  expect(ActionMailer::Base.smtp_settings['password'.to_sym]).to eq password
end

Then(/^ActionMailer's SMTP username is nil$/) do
  expect(ActionMailer::Base.smtp_settings['user_name'.to_sym]).to eq nil
end

Then(/^ActionMailer's SMTP password is nil$/) do
  expect(ActionMailer::Base.smtp_settings['password'.to_sym]).to eq nil
end
