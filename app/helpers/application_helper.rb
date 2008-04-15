# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  ######## Buttons #########
  
  def link_button(text, options = {})
    #TODO check options: img, class, href, target 
    options[:href] ||= "#"
    options[:target] ||= "_self"
    
    '<a href="' + options[:href] + '" target="' + options[:target] + '"' +   
       (options[:class].nil? ? '' : ' class="' + options[:class] + '"') +
       '>' +
       (options[:img].nil? ? '' : image_tag(options[:img])) +
       ' ' + text + '</a>'
  end

  def submit_button(text, options = {})
    #TODO check options: img, class
    options[:form_name] ||= "f"
    '<a href="javascript://donothing" onclick="' + options[:form_name] + '.submit();"' +   
       (options[:class].nil? ? '' : ' class="' + options[:class] + '">') +
       (options[:img].nil? ? '' : image_tag(options[:img])) +
       ' ' + text + '</a>'
  end
  
  def cancel_popup_button(text, options = {})
    link_to_function(text, "parent.parent.GB_hide();")
  end


  ######## Date #########

  def short_time(date)
    date.strftime("%d.%m.%Y - %H:%M")
  end
  
  def short_date(date)
    date.strftime("%d.%m.%Y")
  end
  
  
  
end
