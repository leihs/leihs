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
    $layout_public_path + "/images/icons/" + icon + ".png"
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

  def dates_with_period(start_date, end_date)
    interval = (end_date - start_date).abs + 1
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
        pluralize(interval, _("Day"), _("Days"))
      end
      r
    end
  end
  
  def linked_inventory_pools(inventory_pools)
    html = ""
    inventory_pools.each do |ip|
      html += link_to ip.name, inventory_pool_path(ip)
      html += ", " unless ip == inventory_pools.last
    end
    return html
  end
  
  def compact_inventory_pool_info(inventory_pools)
    html = "".html_safe
    inventory_pools.each do |inventory_pool|
      html += content_tag :section do
        a = content_tag :h3 do
          inventory_pool.name
        end 
        
        a += link_to _("view"), "", :class => 'topright'
        
        a += content_tag :p do
          inventory_pool.opening_hours.gsub('\n','<br>')
        end unless inventory_pool.opening_hours.blank?
        
        a += content_tag :p do
          inventory_pool.address.gsub('\n','<br>')
        end unless inventory_pool.address.blank?
        
        a
      end
      html += content_tag :hr do
      end unless inventory_pool == inventory_pools.last
    end
    return html
  end
  
  def truncate (str, length, suffix = "...")
    if str.is_a?(String) && str.size > length
      str = str[0..length]
      str += suffix
    end
    return str
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

  # let the user know when the search was too short inside a ruby "flash"
  def flash_on_search_result(query, results = nil)
    unless query.blank?
      min_query_len = 0
      if results.blank? or results.options[:classes].nil?
        min_query_len = ThinkingSphinx::Configuration.instance.index_options[:min_infix_len]
      else
        results.options[:classes].each do |klass|
          min_query_len = klass.sphinx_index_options[:min_infix_len] if klass.sphinx_index_options[:min_infix_len] > min_query_len
        end
      end

      if query.length < min_query_len
         flash[:notice] = _("Possibly not all matches are being displayed because your search text was shorter than the minumum %s characters") % min_query_len.to_s
      end    
    end
  end
  
  ######## Hash/Array to <ul> list #########

#old#
#  def to_list(msg = [])
#    content_tag :ul do
#      r = ""
#      msg.to_a.each do |e|
#        r += content_tag :li do
#          e
#        end
#      end
#      r
#    end
#  end
  
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

  ######## Tabs #########

  # TODO 12** optimize rails-widgets overriding
  def tabnav_override(name, opts={}, &block)
    partial_template = opts[:partial] || "widgets/#{name}_tabnav"
    html = capture { render :partial => partial_template }
    if block_given?
      options = {:id => @_tabnav.html[:id] + '_content', :class => @_tabnav.html[:class] + '_content'}
      html += content_tag :div, options do
          capture(&block)
      end
    end
    return html
  end

  def tabnavs(tabs, content)
    if tabs.empty?
      return content
    else
      t = tabs.delete_at(0)
      tabnav_override t do
        tabnavs tabs, content
      end
    end
  end
end
