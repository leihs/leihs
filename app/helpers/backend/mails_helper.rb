module Backend::MailsHelper
  def mail_link( current_inventory_pool, user, source_path, options = nil)
    link_to icon_tag("email_edit") + _("Write Email"),
            new_backend_mail_path(:inventory_pool_id => current_inventory_pool.try(:id),
                                  :user_id => user.try(:id),
                                  :source_path => source_path),
            options
  end
end
