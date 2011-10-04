module Backend::ItemsHelper
  
  def retire_button(item)
    action = (item.retired ? _("Unretire") : _("Retire"))
    greybox_link action, retire_backend_inventory_pool_model_item_path(current_inventory_pool,
                                                                       item.model_id,
                                                                       item,
                                                                       :source_path => request.env['REQUEST_URI'])
  end
  
end
