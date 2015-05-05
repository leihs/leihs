# The Notification class is used as a proxy for sending mails
# (and possibly other kinds of messages).
#
# The idea behind the Notification class is that leihs could
# in principle keep "mailboxes" for users so that f.ex. upon
# login into leihs they could be able to see all the communications
# with the leihs system.
#
class Notification < ActiveRecord::Base

  belongs_to :user, inverse_of: :notifications
  
  def self.order_submitted(order, send_mail = false)
    o = Mailer::Order.submitted(order).deliver if send_mail
    title = (o.nil? ? _('Order submitted') : o.subject)
    Notification.create(user: order.target_user, title: title)
    order.log_history(title, order.target_user.id) if order.target_user
  end

  # Notify the person responsible for the inventory pool that an order
  # was received. Can be enabled in config/environment.rb
  def self.order_received(order, send_mail = false)
    o = Mailer::Order.received(order).deliver if (send_mail and Setting.deliver_order_notifications)
    title = (o.nil? ? _('Order received') : o.subject) # rubocop:disable Lint/UselessAssignment
  end
  
  def self.order_approved(order, comment, send_mail = true, current_user = nil)
    if send_mail
      if order.has_changes?
        o = Mailer::Order.changed(order, comment).deliver
      else
        o = Mailer::Order.approved(order, comment).deliver
      end
    end
    title = (o.nil? ? _('Order approved') : o.subject)
    Notification.create(user: order.target_user, title: title)
    current_user ||= order.target_user
    order.log_history(title, current_user.id)
  end
  
  def self.order_rejected(order, comment, send_mail = true, current_user = nil)
    current_user ||= order.target_user
    o = Mailer::Order.rejected(order, comment).deliver if send_mail
    title = (o.nil? ? _('Order rejected') : o.subject)
    Notification.create(user: order.target_user, title: title)
    order.log_history(title, current_user.id)
  end

  def self.deadline_soon_reminder(user, reservations, send_mail = true)
    reservations.map(&:inventory_pool).uniq.each do |inventory_pool|
      o = Mailer::User.deadline_soon_reminder(user, inventory_pool, reservations).deliver if send_mail
      title = (o.nil? ? _('Deadline soon') : o.subject)
      Notification.create(user: user, title: title)
      user.histories.create(text: title, user_id: user.id, type_const: History::ACTION)
    end
  end
  
  
  def self.remind_user(user, reservations, send_mail = true)
    reservations.map(&:inventory_pool).uniq.each do |inventory_pool|
      o = Mailer::User.remind(user, inventory_pool, reservations).deliver if send_mail
      title = (o.nil? ? _('Reminder') : o.subject)
      Notification.create(user: user, title: title)
      user.histories.create(text: title, user_id: user.id, type_const: History::ACTION)
    end
  end

  def self.user_email(from, to, subject, body)
    Mailer::User.email(from, to, subject, body).deliver
    # we currently do *not* log emails to users
  end
  
end

