class Mailer::User < ActionMailer::Base

  def remind(user, visits, sent_at = Time.now)
    @subject    = _('Remind')
    @body["visits"] = visits
    @recipients = "#{user.email}"
    @from       = 'leihs'
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
  end

end
