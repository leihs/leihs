# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  ######## Buttons #########
  
#  def link_button(text, options = {})
#    #TODO check options: img, class, href, target 
#    options[:href] ||= "#"
#    options[:target] ||= "_self"
#    
#    '<a href="' + options[:href] + '" target="' + options[:target] + '"' +   
#       (options[:class].nil? ? '' : ' class="' + options[:class] + '"') +
#       '>' +
#       (options[:img].nil? ? '' : image_tag(options[:img])) +
#       ' ' + text + '</a>'
#  end

###################################################

  def submit_button(text, options = {})
    #TODO check options: icon, class, id
    options[:form_name] ||= "f"
    '<a href="javascript://donothing" onclick="' + options[:form_name] + '.submit();"' +   
       (options[:id].nil? ? '' : ' id="' + options[:id] + '"') +
       (options[:class].nil? ? '' : ' class="' + options[:class] + '">') +
       (options[:icon].nil? ? '' : icon_tag(options[:icon])) +
       ' ' + text + '</a>'
  end
  
  def cancel_popup_button(text, options = {})
    link_to_function(text, "parent.parent.GB_hide();")
  end
  
  def greybox_link(content, link, options = {}, &block)
    content = capture(&block) if block_given?
    
    on_click_attr = "return " << "GB_showCenter('#{options.delete(:title) || content}', this.href, #{options.delete(:height) || 500}, #{options.delete(:width) || 650}, #{options.delete(:callback) || 'null'})"
    
    link = link_to(content, link, options.merge(:onclick => on_click_attr))
    block_given? && block_is_within_action_view?(block) ? concat(link) : link
  end

  ######## Icon #########

  def icon_path(icon)
    "/assets/icons/" + icon + ".png"
  end

  def icon_tag(icon)
    image_tag(icon_path(icon))#, :style => "vertical-align: bottom;")
  end

  ######## Date #########

  def short_time(date)
    date.strftime("%d.%m.%Y - %H:%M") if date
  end
  
  def short_date(date, tiny = false)
    date.strftime(tiny ? "%d.%m.%y" : "%d.%m.%Y") if date
  end

  def interval(start_date, end_date)
    interval = (end_date - start_date).to_i.abs + 1
    pluralize(interval, _("Day"), _("Days"))
  end

  def dates_with_period(start_date, end_date)
    content_tag :span do
      c = "valid_#{current_inventory_pool.is_open_on?(start_date)}" if current_inventory_pool
      r = content_tag :span, :class => c do
        short_date(start_date)
      end
      r += " - "
      c = "valid_#{current_inventory_pool.is_open_on?(end_date)}" if current_inventory_pool
      r += content_tag :span, :class => c do
        short_date(end_date)
      end
      r += content_tag :br
      r += content_tag :span, :style => "font-size: smaller;" do
        interval(start_date, end_date)
      end
      r
    end
  end
  
  ######## Flash #########

  # OPTIMIZE
  def flash_helper(floating = true)
    if floating
      r = content_tag :div, :id => "flash", :class => "floating", :onclick => "flash_toggle(this);" do
        flash_content
      end
    else
      content_tag :div, :id => "flash" do
        flash_content
      end
    end
  end

  def flash_content
    r = "".html_safe
    [:notice, :error].map do |f|
      r += content_tag(:div, to_list(flash[f]), :class => "#{f}") unless flash[f].blank?
    end
    flash.discard if flash
    r
  end

  ######## Hash/Array to <ul> list #########

  def to_list(h)
    case h.class.name
      when "Hash"
        content_tag :ul do
          r = ""
          h.each_pair do |key,value|
            r += content_tag :li, :style => "padding: 0.5em 0 0 2em;" do
              "<b>#{key}:</b> #{to_list(value)}"
            end
          end
          r
        end
      when "Array"
        content_tag :ul do
          r = ""
          h.each do |value|
            r += content_tag :li, :style => "padding: 0.5em 0 0 2em;" do
              to_list(value)
            end
          end
          r
        end
      else
        auto_link(h, :href_options => { :target => '_blank' })
    end
  end


  ######## User-related methods ###########
  def address_block(user)
    address = "".html_safe
    unless user.address.blank?
      address += user.address
      address += tag :br
    end
    unless (user.zip.blank? and user.city.blank?)
      address += "#{user.zip} #{user.city}"
      address += tag :br
    end
    address
  end
  
  def contact_block(user)
    contact = "".html_safe
    unless user.phone.blank?
      contact += user.phone
      contact += tag :br
    end
    unless user.email.blank?
      contact += user.email
      contact += tag :br
    end 
    contact
  end

end
