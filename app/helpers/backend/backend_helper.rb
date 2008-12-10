module Backend::BackendHelper


  def table_with_search_and_pagination(options = {}, html_options = {}, &block)
    html = content_tag :div, :class => "table-overview", :id => 'list_table' do
        r = search_field_tag(options[:records])
        r += table_tag(options, html_options, &block)
    end
    
    concat(html, block.binding)
  end 


  def search_field_tag(records, query = params[:query], filter = params[:filter])
      query = nil if query.blank?

      content_tag :div, :class => "table-overview", :id => "controller" do
#          content_tag :form do
#            r = ""
#          r = "<form action=\"\">"
#          r = form_remote_tag :url => { }, :html => { :method => :get } #do
#          r = form_remote_tag :update => 'list_table', :html => { :method => :get } #do 
            filter_params = request.path_parameters.keys << "query" << "page"
#            params.each {|k,v| r += hidden_field_tag(k, v) unless filter_params.include?(k) }

            parameters = ""
            params.each {|k,v| parameters += ", #{k}: '#{v}'" unless filter_params.include?(k) }

            r = text_field_tag :query, query, :onchange => "new Ajax.Updater('list_table', '#{url_for({})}', {asynchronous:true, evalScripts:true, method:'get', onLoading:function(request){Element.show('spinner')}, parameters: {query: this.value #{parameters}}}); return false;", :id => 'search_field'
            r += javascript_tag("$('search_field').focus()")
            
            r += content_tag :div, :class => "result", :style => "min-height: 200px;" do
              total = (records.is_a?(ActsAsFerret::SearchResults) ? records.total_hits : records.total_entries)
              s = " <b>#{total}</b> results"
              s += " for <b>#{query}</b>" if query
              s += " filtering <b>#{filter}</b>" if filter
#              w = will_paginate(records, :params => {:query => query})
#              w = will_paginate records, :renderer => 'RemoteLinkRenderer' , :remote => {:with => "'query=' + $('search_field').value", :update => 'list_table'}
              w = will_paginate records, :renderer => 'RemoteLinkRenderer' , :remote => {:update => 'list_table', :loading => "Element.show('spinner')"}
              s += w if w
              s += image_tag("spinner.gif", :id => 'spinner', :style => 'display: none; vertical-align: middle; padding: 0 4px 0 4px;')
              s
            end
#          r += "</form>"
          r
          #end
      end
  end 


  def table_tag(options = {}, html_options = {}, &block)
    content_tag :table do    
      s = content_tag :tr do
        r = ""
        options[:columns].each do |column|
          r += content_tag :th do
             column
          end
        end
        r
      end
  
      options[:records].each do |record|
        s += capture(record, &block)
        # yield(record)
      end
      
      s
    end        
  end


  # TODO 17** buttons_tag
  # <div class="buttons" onclick="if(event.target.hasClassName('ghosted')){ return false; }">

  # TODO 17** ghosted buttons are not preventing right click (open link in New Window, etc)


############################################################################################

  def show_reserver(user)
    content_tag :table do
      content_tag :tr do
        content_tag :td do
          r = _("Reserver") +': '
          r += greybox_link_to_page(user.login,
                    backend_inventory_pool_user_path(@current_inventory_pool, user, :layout => "modal"),
                    :title => _("User"),
                    :class => "iconized-notxt edit-user" )
          r += '<br />'
          r += render :partial => 'backend/users/resume'
          r
        end
      end
    end
  end
    

############################################################################################

  def show_line_model(model)
    html = greybox_link_to_page(model.name,
            backend_inventory_pool_model_path(@current_inventory_pool, model, :layout => "modal"),
            :title => _("Model"),
            :class => "thickbox iconized-notxt edit-package" )

    html += content_tag :ul, :class => "model_group" do
      r = ""
      model.package_items.each do |item|         
        r += content_tag :li do
          "#{item.model.name} (#{item.inventory_code})"
        end
      end
      r
    end if model.is_package? 
    
    return html
  end


############################################################################################

  def enable_tooltip
    javascript_tag do
      '$$(".valid_false").each( function(tip) { new Tooltip(tip, {opacity: ".85", backgroundColor: "#FC9", borderColor: "#C96", textColor: "#000", textShadowColor: "#FFF"}); });
       $$(".with_tooltip").each( function(tip) { new Tooltip(tip, {opacity: ".85", backgroundColor: "#FC9", borderColor: "#C96", textColor: "#000", textShadowColor: "#FFF"}); });'
    end
  end


# TODO 04**
#  def show_tooltip
#  
#  end

############################################################################################


end
