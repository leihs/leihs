Given(/^a settings object$/) do
  @setting = Setting.first
  @setting ||= Setting.create({local_currency_string: 'GBP',
                               email_signature: 'kthxbye',
                               default_email: 'from@example.com'})
end

Given(/^the settings are existing$/) do
  FactoryGirl.create :setting unless Setting.first
end

When(/^the settings are not existing$/) do
  Setting.delete_all
  Setting.class_variable_set :@@singleton, nil
  expect(Setting.count.zero?).to be true
  expect(Setting.smtp_address).to be_nil
end

Then(/^there is an error for the missing settings$/) do
  expect { step 'I go to the home page' }.to raise_error(RuntimeError)
end

