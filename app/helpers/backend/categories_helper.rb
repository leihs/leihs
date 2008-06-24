module Backend::CategoriesHelper


  def display_with_children(categories)
    @displayed ||= Array.new
    output = "<ul class='buttons'>"
    for category in categories
      output << "<li>"
      output << "<h4>" + category.name + "</h4>"
      if @displayed.include?(category)
        output << " * RECURSION *"
      else
        @displayed << category
        output << "<div style='margin-left: 15px;'>"
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
      output << "- " + model.name + "<br />"
    end
    
    output
  end
  


end
