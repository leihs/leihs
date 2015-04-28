Given(/^a settings object$/) do
  @setting = Setting.first
  @setting ||= Setting.create({local_currency_string: 'GBP',
                               email_signature: 'kthxbye',
                               default_email: 'from@example.com'})
end
