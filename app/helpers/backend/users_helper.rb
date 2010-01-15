module Backend::UsersHelper

  def remind_user_link(user, inventory_pool = nil, with_resume = false)
    h = link_to_remote icon_tag("email") + _("Remind"),
                :url => url_for([:remind, :backend, inventory_pool, user].compact),
                :method => :get
    h += remind_user(user) if with_resume
    h
  end

  def remind_user(user)
    unless user.reminders.empty?
      content_tag :span, :id => "remind_resume", :style => "padding: 0.5em;" do
        _("%{i} reminders, last: %{d}") % { :i => user.reminders.size, :d => (short_time user.reminders.last.created_at) }
      end
    else 
      ""
    end
  end

end
