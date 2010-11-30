module Backend::MailsHelper
  def mail_link( current_inventory_pool, user, source_path, options = nil)
    newmailpath = \
      if current_inventory_pool
        new_backend_inventory_pool_mail_path(:inventory_pool => current_inventory_pool,
                                             :user_id => user.try(:id),
                                             :source_path => source_path)
      else
        new_backend_mail_path(:inventory_pool_id => current_inventory_pool.try(:id),
                              :user_id => user.try(:id),
                              :source_path => source_path)
      end

    link_to icon_tag("email_edit") + _("Write Email"), newmailpath, options
  end
end
