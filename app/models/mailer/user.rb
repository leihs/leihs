class Mailer::User < ActionMailer::Base

  def remind(user, visits, sent_at = Time.now)
    @subject    = _('[leihs] Reminder')
    @body["visits"] = visits
    @recipients = "#{user.email}"
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def deadline_soon_reminder(user, visits, sent_at = Time.now)
    @subject    = _('[leihs] Some items should be returned tomorrow')
    @body["visits"] = visits
    @recipients = "#{user.email}"
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = sent_at
    @headers    = {}
  end
  
  

end
