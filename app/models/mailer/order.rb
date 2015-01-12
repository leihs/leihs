class Mailer::Order < ActionMailer::Base

  def choose_language_for(contract)
    #set_locale(contract.target_user.language.locale_name)#NOTE: not working anymore "set_locale"
    I18n.locale = contract.target_user.language.locale_name || I18n.default_locale
  end

  def approved(order, comment, sent_at = Time.now)
    choose_language_for(order)
    mail( :to => order.target_user.email,
          :from => (order.inventory_pool.email || Setting::DEFAULT_EMAIL),
          :subject => _('[leihs] Reservation Confirmation'),
          :date => sent_at ) do |format|
      format.text {
        name = "approved"
        template = MailTemplate.get_template(:order, order.inventory_pool, name, order.target_user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_order(order, comment))
      }
    end
  end

  def submitted(order, purpose, sent_at = Time.now)
    choose_language_for(order)
    mail( :to => order.target_user.email,
          :from => (order.inventory_pool.email || Setting::DEFAULT_EMAIL),
          :subject => _('[leihs] Reservation Submitted'),
          :date => sent_at ) do |format|
      format.text {
        name = "submitted"
        template = MailTemplate.get_template(:order, order.inventory_pool, name, order.target_user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_order(order, nil, purpose))
      }
    end
  end

  def received(order, purpose, sent_at = Time.now)
    choose_language_for(order)
    mail( :to => (order.inventory_pool.email || Setting::DEFAULT_EMAIL),
          :from => (order.inventory_pool.email || Setting::DEFAULT_EMAIL),
          :subject => _('[leihs] Order received'),
          :date => sent_at ) do |format|
      format.text {
        name = "received"
        template = MailTemplate.get_template(:order, order.inventory_pool, name, order.target_user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_order(order, nil, purpose))
      }
    end
  end

  def rejected(order, comment, sent_at = Time.now)
    choose_language_for(order)
    mail( :to => order.target_user.email,
          :from => (order.inventory_pool.email || Setting::DEFAULT_EMAIL),
          :subject => _('[leihs] Reservation Rejected'),
          :date => sent_at ) do |format|
      format.text {
        name = "rejected"
        template = MailTemplate.get_template(:order, order.inventory_pool, name, order.target_user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_order(order, comment))
      }
    end
  end

  def changed(order, comment, sent_at = Time.now)
    choose_language_for(order)
    mail( :to => order.target_user.email,
          :from => (order.inventory_pool.email || Setting::DEFAULT_EMAIL),
          :subject => _('[leihs] Reservation confirmed (with changes)'),
          :date => sent_at ) do |format|
      format.text {
        name = "changed"
        template = MailTemplate.get_template(:order, order.inventory_pool, name, order.target_user.language)
        Liquid::Template.parse(template).render(MailTemplate.liquid_variables_for_order(order, comment))
      }
    end
  end

end
