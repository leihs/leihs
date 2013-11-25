# -*- encoding : utf-8 -*-

Angenommen(/^Das System ist für den Mailversand im Testmodus konfiguriert$/) do
  setting = Setting.first

  # Need to have these settings, otherwise we can't save. Ouch, coupling.
  if not setting
    setting = Setting.new
    setting[:local_currency_string] = 'GBP'
    setting[:email_signature] = 'Cheers,'
    setting[:default_email] = 'sender@example.com'
  end
  setting[:mail_delivery_method] = 'test'
  setting.save.should be_true
end

Angenommen(/^ich habe eine verspätete Rückgabe$/) do
  jump_to_date = @current_user.contract_lines.to_take_back.first.end_date + 1.day
  back_to_the_future(jump_to_date)
  overdue_lines = @current_user.contract_lines.to_take_back.where("end_date < CURDATE()")
  overdue_lines.empty?.should be_false
end

Angenommen(/^ich habe eine nicht verspätete Rückgabe$/) do
  jump_to_date = @current_user.contract_lines.to_take_back.first.end_date - 1.day
  back_to_the_future(jump_to_date)
  deadline_soon_lines = @current_user.contract_lines.to_take_back.where("end_date > CURDATE()")
  deadline_soon_lines.empty?.should be_false
end

Dann(/^wird mir einen Tag vor der Rückgabe eine Erinnerungs E-Mail zugeschickt$/) do
  ActionMailer::Base.deliveries.empty?.should be_true
  @current_user.notifications.reload.empty?.should be_true

  User.send_deadline_soon_reminder_to_everybody

  ActionMailer::Base.deliveries.empty?.should be_false
  @current_user.notifications.reload.empty?.should be_false

  ActionMailer::Base.deliveries.detect {|x| x.to.include? @current_user.email}.nil?.should be_false
end

Dann(/^erhalte ich einen Tag nach Rückgabedatum eine Erinnerungs E\-Mail zugeschickt$/) do
  ActionMailer::Base.deliveries.empty?.should be_true
  @current_user.notifications.reload.empty?.should be_true

  User.remind_all

  ActionMailer::Base.deliveries.empty?.should be_false
  @current_user.notifications.reload.empty?.should be_false

  ActionMailer::Base.deliveries.detect {|x| x.to == @current_user.emails }.nil?.should be_false
end

Dann(/^für jeden weiteren Tag erhalte ich erneut eine Erinnerungs E\-Mail zugeschickt$/) do
  ActionMailer::Base.deliveries.clear
  back_to_the_future(Date.tomorrow)

  ActionMailer::Base.deliveries.empty?.should be_true
  @current_user.notifications.reload.empty?.should be_false

  User.remind_all

  ActionMailer::Base.deliveries.empty?.should be_false
  @current_user.notifications.reload.empty?.should be_false

  ActionMailer::Base.deliveries.detect {|x| x.to == @current_user.emails }.nil?.should be_false
end

