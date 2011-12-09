class Mailer::User < ActionMailer::Base


  def choose_language_for(user)
    #set_locale(user.language.locale_name)#NOTE: not working anymore "set_locale"
    I18n.locale = user.language.locale_name || I18n.default_locale
  end

  def remind(user, visits, sent_at = Time.now)
    choose_language_for(user)
    @visits = visits
    mail( :to => user.emails,
          :from => (visits.first.inventory_pool.email || DEFAULT_EMAIL),
          :subject => _('[leihs] Reminder'),
          :date => sent_at )
  end
  
  def deadline_soon_reminder(user, visits, sent_at = Time.now)
    choose_language_for(user)
    @visits = visits
    mail( :to => user.emails,
          :from => (visits.first.inventory_pool.email || DEFAULT_EMAIL),
          :subject => _('[leihs] Some items should be returned tomorrow'),
          :date => sent_at )
  end
  
  
  def email(from, to, subject, body)
    @email = body
    mail( :to => to,
          :from => from,
          :subject => "[leihs] #{subject}",
          :date => Time.now )
  end
  

end
