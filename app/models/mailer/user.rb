class Mailer::User < ActionMailer::Base

  def choose_language_for(user)
    language = user.language.try(:locale_name) || Language.default_language.try(:locale_name)
    I18n.locale = language || I18n.default_locale
  end

  def remind(user, inventory_pool, visit_lines, sent_at = Time.now)
    choose_language_for(user)
    mail(to: user.emails,
         from: (inventory_pool.email || Setting::DEFAULT_EMAIL),
         subject: _('[leihs] Reminder'),
         date: sent_at) do |format|
      format.text {
        name = "reminder"
        template = MailTemplate.get_template(:user, inventory_pool, name, user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_user(user, inventory_pool, visit_lines))
      }
    end
  end

  def deadline_soon_reminder(user, inventory_pool, visit_lines, sent_at = Time.now)
    choose_language_for(user)
    mail(:to => user.emails,
         :from => (inventory_pool.email || Setting::DEFAULT_EMAIL),
         :subject => _('[leihs] Some items should be returned tomorrow'),
         :date => sent_at) do |format|
      format.text {
        name = "deadline_soon_reminder"
        template = MailTemplate.get_template(:user, inventory_pool, name, user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_user(user, inventory_pool, visit_lines))
      }
    end
  end


  def email(from, to, subject, body)
    @email = body
    mail(:to => to,
         :from => from,
         :subject => "[leihs] #{subject}",
         :date => Time.now)
  end

end
