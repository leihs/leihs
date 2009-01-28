class Mailer::Order < ActionMailer::Base

  def approved(order, comment, sent_at = Time.now)
    @subject    = _('[leihs] Reservation Confirmation')
    @body["order"] = order
    @body["comment"] = comment
    @recipients = "#{order.user.email}"
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = sent_at
    @headers    = {}
  end

  def submitted(order, purpose, sent_at = Time.now)
    @subject    = _('[leihs] Reservation Submitted')
    @body["order"] = order
    @body["purpose"] = purpose
    @recipients = "#{order.user.email}"
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = sent_at
    @headers    = {}
  end

  def rejected(order, comment, sent_at = Time.now)
    @subject    = _('[leihs] Reservation Rejected')
    @body["order"] = order
    @body["comment"] = comment
    @recipients = "#{order.user.email}"
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = sent_at
    @headers    = {}
  end

  def changed(order, comment, sent_at = Time.now)
    @subject    = _('[leihs] Reservation confirmed (with changes)')
    @body["order"]  = order
    @body["comment"] = comment
    
    @recipients = "#{order.user.email}"
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = sent_at
    @headers    = {}
  end
end
