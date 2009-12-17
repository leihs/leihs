class Mailer::Order < ActionMailer::Base


  def choose_language_for(user)
    set_locale(user.language.locale_name)
  end


  def approved(order, comment, sent_at = Time.now)
    choose_language_for(order.user)
    @subject    = _('[leihs] Reservation Confirmation')
    @body["order"] = order
    @body["comment"] = comment
    @recipients = "#{order.user.email}"
    @from       = order.inventory_pool.email || DEFAULT_EMAIL
    @sent_on    = sent_at
    @headers    = {}
  end

  def submitted(order, purpose, sent_at = Time.now)
    choose_language_for(order.user)
    @subject    = _('[leihs] Reservation Submitted')
    @body["order"] = order
    @body["purpose"] = purpose
    @recipients = "#{order.user.email}"
    @from       = order.inventory_pool.email || DEFAULT_EMAIL
    @sent_on    = sent_at
    @headers    = {}
  end

  def rejected(order, comment, sent_at = Time.now)
    choose_language_for(order.user)
    @subject    = _('[leihs] Reservation Rejected')
    @body["order"] = order
    @body["comment"] = comment
    @recipients = "#{order.user.email}"
    @from       = order.inventory_pool.email || DEFAULT_EMAIL
    @sent_on    = sent_at
    @headers    = {}
  end

  def changed(order, comment, sent_at = Time.now)
    choose_language_for(order.user)
    @subject    = _('[leihs] Reservation confirmed (with changes)')
    @body["order"]  = order
    @body["comment"] = comment
    
    @recipients = "#{order.user.email}"
    @from       = order.inventory_pool.email || DEFAULT_EMAIL
    @sent_on    = sent_at
    @headers    = {}
  end
end
