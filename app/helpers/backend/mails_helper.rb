module Backend::MailsHelper

# EVERYTHING AFTER HERE IS OLD STUFF
=begin
  def mail_link( current_inventory_pool, user, source_path, options = {})
    modal = options.slice(:layout)
    newmailpath = \
      if current_inventory_pool
        new_backend_inventory_pool_mail_path( { :inventory_pool => current_inventory_pool,
                                                :user_id => user.try(:id),
                                                :source_path => source_path}.merge(modal) )
      else
        new_backend_mail_path( { :inventory_pool_id => current_inventory_pool.try(:id),
                                 :user_id => user.try(:id),
                                 :source_path => source_path }.merge(modal))
      end

    link_to icon_tag("email_edit") + _("Write Email"), newmailpath, options
  end
=end
end
