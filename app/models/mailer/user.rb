class Mailer::User < ActionMailer::Base

  def choose_language_for(user)
    language = user.language.try(:locale_name) || Language.default_language.try(:locale_name)
    I18n.locale = language || I18n.default_locale
  end

  def remind(visits, sent_at = Time.now)
    visits.flat_map(&:visit_lines).group_by {|vl| {inventory_pool_id: vl.inventory_pool_id, user_id: (vl.delegated_user_id || vl.user_id)} }.each_pair do |k,v|
      @inventory_pool = InventoryPool.find(k[:inventory_pool_id])
      user = User.find(k[:user_id])
      choose_language_for(user)
      @visit_lines = v
      mail( :to => user.emails,
            :from => (@inventory_pool.email || Setting::DEFAULT_EMAIL),
            :subject => _('[leihs] Reminder'),
            :date => sent_at )
    end
  end
  
  def deadline_soon_reminder(visits, sent_at = Time.now)
    visits.flat_map(&:visit_lines).group_by {|vl| {inventory_pool_id: vl.inventory_pool_id, user_id: (vl.delegated_user_id || vl.user_id)} }.each_pair do |k,v|
      @inventory_pool = InventoryPool.find(k[:inventory_pool_id])
      user = User.find(k[:user_id])
      choose_language_for(user)
      @visit_lines = v
      mail( :to => user.emails,
            :from => (@inventory_pool.email || Setting::DEFAULT_EMAIL),
            :subject => _('[leihs] Some items should be returned tomorrow'),
            :date => sent_at )
    end
  end
  
  
  def email(from, to, subject, body)
    @email = body
    mail( :to => to,
          :from => from,
          :subject => "[leihs] #{subject}",
          :date => Time.now )
  end
  

end
