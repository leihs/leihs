# -*- encoding : utf-8 -*-

Given(/^the system is configured for the mail delivery as test mode$/) do
  setting = Setting.first

  # Need to have these settings, otherwise we can't save. Ouch, coupling.
  if not setting
    setting = Setting.new
    setting[:local_currency_string] = 'GBP'
    setting[:email_signature] = 'Cheers,'
    setting[:default_email] = 'sender@example.com'
  end
  setting[:mail_delivery_method] = 'test'
  expect(setting.save).to be true
end

Given(/^I have an overdue take back$/) do
  jump_to_date = @current_user.reservations.signed.first.end_date + 1.day
  Dataset.back_to_date(jump_to_date)
  overdue_lines = @current_user.reservations.signed.where('end_date < ?', Date.today)
  expect(overdue_lines.empty?).to be false
end

Given(/^I have a non overdue take back$/) do
  jump_to_date = @current_user.reservations.signed.first.end_date - 1.day
  Dataset.back_to_date(jump_to_date)
  deadline_soon_lines = @current_user.reservations.signed.where('end_date > ?', Date.today)
  expect(deadline_soon_lines.empty?).to be false
end

Then(/^the day before the take back I receive a deadline soon email$/) do
  expect(ActionMailer::Base.deliveries.empty?).to be true
  expect(@current_user.notifications.reload.empty?).to be true

  User.send_deadline_soon_reminder_to_everybody

  expect(ActionMailer::Base.deliveries.empty?).to be false
  expect(@current_user.notifications.reload.empty?).to be false

  expect(ActionMailer::Base.deliveries.detect {|x| x.to.include? @current_user.email}.nil?).to be false
end

Then(/^the day after the take back I receive a remember email$/) do
  expect(ActionMailer::Base.deliveries.empty?).to be true
  expect(@current_user.notifications.reload.empty?).to be true

  User.remind_and_suspend_all

  expect(ActionMailer::Base.deliveries.empty?).to be false
  expect(@current_user.notifications.reload.empty?).to be false

  expect(ActionMailer::Base.deliveries.detect {|x| x.to == @current_user.emails }.nil?).to be false
end

Then(/^for each further day I receive an additional remember email$/) do
  ActionMailer::Base.deliveries.clear
  Dataset.back_to_date(Date.tomorrow)

  expect(ActionMailer::Base.deliveries.empty?).to be true
  expect(@current_user.notifications.reload.empty?).to be false

  User.remind_and_suspend_all

  expect(ActionMailer::Base.deliveries.empty?).to be false
  expect(@current_user.notifications.reload.empty?).to be false

  expect(ActionMailer::Base.deliveries.detect {|x| x.to == @current_user.emails }.nil?).to be false
end

