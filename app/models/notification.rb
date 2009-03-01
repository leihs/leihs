class Notification < ActiveRecord::Base
  belongs_to :user
  
  
  def self.order_submitted(order, purpose, send_mail = false)
    o = Mailer::Order.deliver_submitted(order, purpose) if send_mail
    title = (o.nil? ? _("Order submitted") : o.subject)
    Notification.create(:user => order.user, :title => title)
    order.log_history(title, order.user.id) if order.user
    #puts o
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
    order.log_history(title, order.user.id)
  end
  
  def self.order_rejected(order, comment, send_mail = true)
    o = Mailer::Order.deliver_rejected(order, comment) if send_mail
    title = (o.nil? ? _("Order rejected") : o.subject)
    Notification.create(:user => order.user, :title => title)
    order.log_history(title, order.user.id)
    #puts o
  end
  
  def self.deadline_soon_reminder(user, visits, send_mail = true)
    o = Mailer::User.deliver_deadline_soon_reminder(user, visits) if send_mail
    title = (o.nil? ? _("Deadline soon") : o.subject)
    Notification.create(:user => user, :title => title)
    user.histories.create(:text => title, :user_id => user.id, :type_const => History::ACTION)
  end
  
  
  def self.remind_user(user, visits, send_mail = true)
    o = Mailer::User.deliver_remind(user, visits) if send_mail
    title = (o.nil? ? _("Reminder") : o.subject)
    Notification.create(:user => user, :title => title)
    user.histories.create(:text => title, :user_id => user.id, :type_const => History::ACTION)
  end
  
end
