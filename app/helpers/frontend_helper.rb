module FrontendHelper
  
  def category_cell(category)
    html =  '<div class="cell">'
    html += '<a href=""><img src="http://dl.dropbox.com/u/9864549/final_cat_pics/audio.jpg" alt=""/></a> <!-- Category Image -->'
            
    html += "<h2><a href=\"\">#{category.name}</a></h2>"
    html += "<ul>"
    category.children.each do |d|
      html += "<li>#{d.name}</li>"
    end
    html += "</ul>"
    html +="</div>"
    return html
  end

end