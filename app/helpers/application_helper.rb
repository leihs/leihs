# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  ######## Buttons #########
  
  # TODO do we need it?
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
    date.strftime("%d.%m.%Y - %H:%M") if date
  end
  
  def short_date(date)
    date.strftime("%d.%m.%Y") if date
  end
  
  
  ######## Search #########

  ACTION_DICTIONARY = { "add_line" => ["Add", "package_add"],
                        "swap_model_line" => ["Swap", "arrow_switch"],
                        "swap_user" => ["Swap", "arrow_switch"]}
  
  def get_action_text(action)
    ACTION_DICTIONARY[action][0]
  end

  def get_action_image(action)
    ACTION_DICTIONARY[action][1]
  end
  
  
end
