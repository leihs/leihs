class Notification < ActiveRecord::Base
  belongs_to :user
  
  
  def self.order_submitted(order, purpose, send_mail = false)
    o = Mailer::Order.deliver_submitted(order, purpose) if send_mail
    title = (o.nil? ? _("Order submitted") : o.subject)
    Notification.create(:user => order.user, :title => title)
  end
  
  def self.order_approved(order, comment, send_mail = true)
    if send_mail
      if order.has_changes?
        o = Mailer::Order.deliver_changed(order, comment)
      else
        o = Mailer::Order.deliver_approved(order, comment)
      end
    end
    title = (o.nil? ? _("Order approved") : o.subject)
    Notification.create(:user => order.user, :title => title)
  end
  
  def self.order_rejected(order, comment, send_mail = true)
    o = Mailer::Order.deliver_rejected(order, comment) if send_mail
    title = (o.nil? ? _("Order rejected") : o.subject)
    Notification.create(:user => order.user, :title => title)
  end
  
  def self.remind_user(user, visits, send_mail = true)
    o = Mailer::User.deliver_remind(user, visits) if send_mail
    title = (o.nil? ? _("Reminder") : o.subject)
    Notification.create(:user => user, :title => title)
  end
  
end
