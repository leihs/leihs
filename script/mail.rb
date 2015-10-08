require 'optparse'

class MyMailer < ActionMailer::Base
  # Don't call this method "message", that's a reserved word
  def generic_message(recipients, subject, body)
      mail(to: recipients,
           from: Setting.default_email,
           subject: subject,
           body: body)
  end
end

options = OpenStruct.new
options.recipients = ''
options.subject = 'No subject'
options.body = 'No message.'

OptionParser.new do |opts|
  opts.banner = 'Usage: rails runner mail.rb [options]'

  opts.on('-r', '--recipients RECIPIENTS', Array, 'The recipients of the email, comma-separated, no spaces') do |r|
    options.recipients = r
  end

  opts.on('-s', '--subject [SUBJECT]', 'The subject of the email') do |s|
    options.subject = s
  end

  opts.on('-b', '--body [BODY]', 'The body of the email') do |b|
    options.body = b
  end
end.parse!

message = MyMailer.generic_message(options.recipients, options.subject, options.body)
if message.deliver_now
  puts "Sent email to #{options.recipients.join(',')}."
  exit 0
else
  $stderr.puts "Could not send email to #{options.recipients.join(',')}."
  exit 1
end
