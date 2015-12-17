class Mailer::Order < ActionMailer::Base

  def choose_language_for(contract)
    I18n.locale = contract.target_user.language.locale_name || I18n.default_locale
  end

  def approved(order, comment, sent_at = Time.zone.now)
    choose_language_for(order)
    mail(to: order.target_user.email,
         from: (order.inventory_pool.email || Setting.default_email),
         subject: _('[leihs] Reservation Confirmation'),
         date: sent_at) do |format|
      format.text do
        name = 'approved'
        template = MailTemplate.get_template(:order,
                                             order.inventory_pool,
                                             name,
                                             order.target_user.language)
        Liquid::Template
          .parse(template)
          .render(MailTemplate.liquid_variables_for_order(order, comment))
      end
    end
  end

  def submitted(order, sent_at = Time.zone.now)
    choose_language_for(order)
    mail(to: order.target_user.email,
         from: (order.inventory_pool.email || Setting.default_email),
         subject: _('[leihs] Reservation Submitted'),
         date: sent_at) do |format|
      format.text do
        name = 'submitted'
        template = MailTemplate.get_template(:order,
                                             order.inventory_pool,
                                             name,
                                             order.target_user.language)
        Liquid::Template
          .parse(template)
          .render(MailTemplate.liquid_variables_for_order(order, nil))
      end
    end
  end

  def received(order, sent_at = Time.zone.now)
    choose_language_for(order)
    mail(to: (order.inventory_pool.email || Setting.default_email),
         from: (order.inventory_pool.email || Setting.default_email),
         subject: _('[leihs] Order received'),
         date: sent_at) do |format|
      format.text do
        name = 'received'
        template = MailTemplate.get_template(:order,
                                             order.inventory_pool,
                                             name,
                                             order.target_user.language)
        Liquid::Template
          .parse(template)
          .render(MailTemplate.liquid_variables_for_order(order, nil))
      end
    end
  end

  def rejected(order, comment, sent_at = Time.zone.now)
    choose_language_for(order)
    mail(to: order.target_user.email,
         from: (order.inventory_pool.email || Setting.default_email),
         subject: _('[leihs] Reservation Rejected'),
         date: sent_at) do |format|
      format.text do
        name = 'rejected'
        template = MailTemplate.get_template(:order,
                                             order.inventory_pool,
                                             name,
                                             order.target_user.language)
        Liquid::Template
          .parse(template)
          .render(MailTemplate.liquid_variables_for_order(order, comment))
      end
    end
  end

end
