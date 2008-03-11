class OrderMailer < ActionMailer::Base

  def approved(order, sent_at = Time.now)
    @subject    = _('Reservation Confirmation')
    @body["order"] = order
    @recipients = "#{order.user.email}"
    @from       = 'leihs'
    @sent_on    = sent_at
    @headers    = {}
  end

  def rejected(order, sent_at = Time.now)
    @subject    = 'OrderMailer#rejected'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end

  def changed(order, sent_at = Time.now)
    @subject    = 'OrderMailer#changed'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end
