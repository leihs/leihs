module ModelsHelper

  def display_with_children(categories, parent = nil)
    output = "<ul class='model_group'>"
    for category in categories
      next unless @categories.include?(category)
      output << "<li class='#{category.type}'>"
      output << "<span>" + (parent ? category.label(parent) : category.name)
      output << "<span style='padding-left: 10px;'>" + link_to_remote(_("Add"), :update => 'basket', :url => {:controller => 'orders', :action => 'add_line', :model_group_id => category.id}) + "</span>" if category.type == "Package" or category.type == "Template"
      output << "</span>"

      output << "<div>"
      output << display_models(category.model_links)
      output << display_with_children(category.children, category)
      output << "</div>"

      output << "</li>"
    end
    output << "</ul>"
    
    output
  end
  
  def display_models(model_links)
    output = ""
    for model_link in model_links
      if @models.include?(model_link.model)
        if model_link.model_group.is_a?(Category)
          label_quantity = ""
          label_add = "<span class='add_button'>(#{model_link.model.items.size}) "
          label_add << link_to_remote(_("Add"), :update => 'basket', :url => {:controller => 'orders', :action => 'add_line', :model_id => model_link.model.id}) 
          label_add << "</span>"
        else
          label_quantity = "#{model_link.quantity}x "
          label_add = ""
        end            
        output << link_to_remote(label_quantity + "#{model_link.model.name}", :update => 'details', :url => {:controller => 'models', :action => 'details', :id => model_link.model.id})
        output << label_add + "<br />"
      end
    end
    
    output
  end

end
