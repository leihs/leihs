class Mailer::User < ActionMailer::Base


  def choose_language_for(user)
    language = user.language.try(:locale_name) || Language.default_language
    set_locale(language) 
  end

  def remind(user, visits, sent_at = Time.now)
    choose_language_for(user)
    @subject    = _('[leihs] Reminder')
    @body["visits"] = visits
    @recipients = "#{user.email}"
    @from       = visits.first.inventory_pool.email || DEFAULT_EMAIL
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def deadline_soon_reminder(user, visits, sent_at = Time.now)
    choose_language_for(user)
    @subject    = _('[leihs] Some items should be returned tomorrow')
    @body["visits"] = visits
    @recipients = "#{user.email}"
    @from       = visits.first.inventory_pool.email || DEFAULT_EMAIL
    @sent_on    = sent_at
    @headers    = {}
  end
  
  
  def email(from, to, subject, body)
    @subject    = '[leihs] ' + subject
    @body["email"] = body
    @recipients = to
    @from       = from
    @sent_on    = Time.now
    @headers    = {}
  end
  

end
