module ModelsHelper

  def display_with_children(categories, parent = nil)
    output = "<ul class='category'>"
    for category in categories
      next unless @categories.include?(category)
      output << "<li>"
      output << "<span>" + (parent ? category.label(parent) : category.name) + "</span>"

        output << "<div>"
        output << display_models(category.models)
        output << display_with_children(category.children, category)
        output << "</div>"

      output << "</li>"
    end
    output << "</ul>"
    
    output
  end
  
  def display_models(models)
    output = ""
    for model in models
      if @models.include?(model)
        if model.is_package?
          output << display_add_label(model, "(package)")
        else
          for ip in model.inventory_pools
              output << display_add_label(model, "[#{ip.name}] (#{ip.items.count(:conditions => {:model_id => model.id})})")
          end
        end
      end
    end
    
    output
  end

  def display_add_label(model, label)
    output = ""
    output << link_to_remote(model.name, :update => 'details', :url => {:controller => 'models', :action => 'details', :id => model.id})
    output << "<span class='add_button'>#{label} "
    output << link_to_remote(_("Add"), :update => 'basket', :url => {:controller => 'orders', :action => 'add_line', :model_id => model.id}) 
    output << "</span><br />"
    output
  end

end
