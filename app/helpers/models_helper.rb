module ModelsHelper

  def display_with_children(categories)
    output = "<ul class='category'>"
    for category in categories
      next unless @categories.include?(category)
      output << "<li>"
      output << "<span>" + category.name + "</span>"
      if false #category.parents.include?(category) # TODO prevent loops
        output << " * RECURSION *"
      else
        output << "<div>"
        output << display_models(category.models)
        output << display_with_children(category.children)
        output << "</div>"
      end
      output << "</li>"
    end
    output << "</ul>"
    
    output
  end
  
  def display_models(models)
    output = ""
    for model in models
      for ip in model.inventory_pools
        if @models.include?(model)
          output << "- #{model.name}"
          output << "<span class='add_button'>[#{ip.name}] (#{ip.items.count(:conditions => {:model_id => model.id})}) "
          output << link_to(_("Add"),
               { :controller => '/orders', :action => 'add_line', :id => current_user.get_current_order, :model_id => model.id },
                :method => 'post', :target=> '_top')
          output << "</span><br />"
        end
      end      
    end
    
    output
  end

end
