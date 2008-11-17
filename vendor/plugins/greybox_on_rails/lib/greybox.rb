# Greybox
module Greybox
  include ActionView::Helpers::CaptureHelper
  
  def greybox_head(absolute_path = nil)
    if absolute_path.nil?
      # if not passed in, just guess the location.  Probably right anyway.
      absolute_path = "#{request.protocol.to_s}#{request.host_with_port.to_s}/greybox/"
    end
    absolute_path << "/" unless absolute_path =~ /\/$/
    ap_no_trailing = absolute_path.gsub(/\/$/, '')
    "<script type=\"text/javascript\">
        var GB_ROOT_DIR = \"#{absolute_path}\";
    </script>
    <script type=\"text/javascript\" src=\"#{ap_no_trailing}/AJS.js\"></script>
    <script type=\"text/javascript\" src=\"#{ap_no_trailing}/AJS_fx.js\"></script>
    <script type=\"text/javascript\" src=\"#{ap_no_trailing}/gb_scripts.js\"></script>
    <link href=\"#{ap_no_trailing}/gb_styles.css\" rel=\"stylesheet\" type=\"text/css\" />"
  end
  
  # Expects a block for link.
  # examples:
  #   <%= greybox_link_to_image(image_tag('rockies_thumb.jpg'), "/images/rocky_mountains.jpg", 
  #         :title => 'From my trip to the rockies!') %>
  # also can be used as a block:
  # <% greybox_link_to_image nil, "/images/rocky_mountains.jpg", :title => 'From my trip to the rockies!' do
  #     image_tag('rockies_thumb.jpg')
  # <% end %>
  # valid options are:
  # :title, any from link_to (except rel)
  def greybox_link_to_image(content, link, options = {}, &block)
    # <a href="http://static.flickr.com/119/294309231_a3d2a339b9.jpg" title="Flower" rel="gb_image[]">Show flower</a>
    content = capture(&block) if block_given?
    link = link_to(content, link, options.merge(
      :rel => @greybox_group_name.nil? ? 'gb_image[]' : "gb_imageset[#{@greybox_group_name}]"))
    block_given? && block_is_within_action_view?(block) ? concat(link, block.binding) : link
  end

  # Expects a block for link.
  # examples: 
  #   <%= greybox_link_to_page(nil, "http://www.google.ca", :title => 'This is google!') do
  #     image_tag('google_image.jpg')
  #   end %>
  # and.. 
  #   <%= greybox_link_to_page("View Google!", "http://www.google.ca", :title => 'This is google!') %>
  # valid options are (only valid when not in page groups?):
  # :fullscreen => false|true  
  # :width
  # :height
  def greybox_link_to_page(content, link, options = {}, &block)
    # <a href="http://google.com/" title="Google" rel="gb_page_center[500, 500]">Launch Google.com</a>
    # <a href="http://google.com/" title="Google" rel="gb_page_fs[]">Launch Google.com</a>
    content = capture(&block) if block_given?
    rel_attr = @greybox_group_name.nil? ? (options.delete(:fullscreen) ? 'gb_page_fs[]' : "gb_page_center[#{options.delete(:width) || 650}, #{options.delete(:height) || 500}]") : "gb_pageset[#{@greybox_group_name}]"
    link = link_to(content, link, options.merge(:rel => rel_attr))
    block_given? && block_is_within_action_view?(block) ? concat(link, block.binding) : link
  end

  # Wrap this around a block of greybox_link_to_whatever calls to make them show up in a group,
  # expects one parameter of the name of the group.
  # greybox_links "Nice pics" do
  #   greybox_link_to_image "sunset", "sunset.jpg"
  #   greybox_link_to_image "sunset 2", "sunset2.jpg"
  # end
  def greybox_links(name, &block)
    # <a href="static_files/salt.jpg" rel="gb_imageset[nice_pics]" title="Salt flats in Chile">Salt flats</a>
    # <a href="static_files/night_valley.jpg" rel="gb_imageset[nice_pics]" title="Night valley">Night valley</a>
    # and ...
    # <a href="http://google.com/" title="Google" rel="gb_pageset[search_sites]">Launch Google search</a>
    # <a href="http://search.yahoo.com/" rel="gb_pageset[search_sites]">Launch Yahoo search</a>
    @greybox_group_name = name.downcase.gsub(' ', '_')
    result = capture(&block)
    @greybox_group_name = nil
    block_is_within_action_view?(block) ? concat(result, block.binding) : result
  end
  
  # Expects a block for link.
  # examples: 
  #   <%= greybox_link_to_page(nil, "http://www.google.ca", :title => 'This is google!') do
  #     image_tag('google_image.jpg')
  #   end %>
  # and.. 
  #   <%= greybox_link_to_page("View Google!", "http://www.google.ca", :title => 'This is google!') %>
  # valid options are (only valid when not in page groups?):
  # :fullscreen => false|true  
  # :width
  # :height
  def greybox_advance_link_to_page(content, link, options = {}, &block)
    # <a href="http://google.com/" onclick="return GB_showFullScreen('Google', this.href)">Visit Google</a>
    # <a href="http://google.com/" onclick="return GB_showCenter('Google', this.href)">Visit Google</a>
    # <a href="http://google.com/" onclick="return GB_show('Google', this.href)">Visit Google</a>
    content = capture(&block) if block_given?
    
    on_click_attr = "return " << (options.delete(:fullscreen) ? "GB_showFullScreen('#{content}', this.href)" : (options.delete(:center) ? "GB_showCenter('#{content}', this.href, #{options.delete(:height) || 500}, #{options.delete(:width) || 650})" : "GB_show('#{content}', this.href, #{options.delete(:height) || 500}, #{options.delete(:width) || 650})"))
    
    link = link_to(content, link, options.merge(:onclick => on_click_attr))
    block_given? && block_is_within_action_view?(block) ? concat(link, block.binding) : link
  end
    
  private
  def block_is_within_action_view?(block)
    eval("defined? _erbout", block.binding)
  end
end