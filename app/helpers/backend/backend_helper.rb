module Backend::BackendHelper

  def table(options = {}, html_options = {}, &block)
    html = table_tag(options, html_options, &block)
    concat(html, block.binding)
  end

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
            filter_params = request.path_parameters.keys << "query" << "page"
            parameters = ""
            params.each {|k,v| parameters += ", #{k}: '#{v}'" unless filter_params.include?(k) }

            r = text_field_tag :query, query, :onchange => "new Ajax.Updater('list_table', '', {asynchronous:true, evalScripts:true, method:'get', onLoading:function(request){Element.show('spinner')}, parameters: {query: this.value #{parameters}}}); return false;", :id => 'search_field'
            r += javascript_tag("$('search_field').focus()")
            
            r += content_tag :div, :class => "result", :style => "min-height: 200px;" do
              total = (records.is_a?(ActsAsFerret::SearchResults) ? records.total_hits : records.total_entries)
              s = _(" <b>%d</b> results") % total
              s += _(" for <b>%s</b>") % query if query
              s += _(" filtering <b>%s</b>") % filter if filter
              w = will_paginate records, :renderer => 'RemoteLinkRenderer' , :remote => {:update => 'list_table', :loading => "Element.show('spinner')"}, :previous_label => _("Previous"), :next_label => _("Next")
              s += w if w
              s += image_tag("spinner.gif", :id => 'spinner', :style => 'display: none;', :class => "loading_spinner")
              s
            end
          r
      end
  end 


  def table_tag(options = {}, html_options = {}, &block)
    content_tag :table do
      s = ""
      s += content_tag :tr do
        r = ""
        options[:columns].each do |column|
          r += content_tag :th, :style => "white-space:nowrap;" do
            p = ""
            if column.is_a?(Array)
              b = (params[:sort] == column[1])
              dir = (params[:dir] == "ASC" ? "DESC" : "ASC") if b
              p += link_to_remote column[0],
                :url => params.merge({ :sort => column[1], :dir => dir, :page => 1}),
                :method => :get,
                :form => true,
                :update => 'list_table',
                :loading => "Element.show('spinner')"
              p += icon_tag("arrow_" + (params[:dir] == "ASC" ? "down" : "up")) if b
            else
              p += column
            end
            p
          end
        end
        r
      end unless options[:columns].blank?
  
      options[:records].each do |record|
        s += capture(record, &block)
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
            :class => "thickbox iconized-notxt edit-package", :width => 1000 )

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
#temp#    
#    javascript_tag do
#      '$$(".valid_false").each( function(tip) { new Tooltip(tip, {opacity: ".85", backgroundColor: "#FC9", borderColor: "#C96", textColor: "#000", textShadowColor: "#FFF"}); });
#       $$(".with_tooltip").each( function(tip) { new Tooltip(tip, {opacity: ".85", backgroundColor: "#FC9", borderColor: "#C96", textColor: "#000", textShadowColor: "#FFF"}); });'
#    end
  end


# TODO 04**
#  def show_tooltip
#  
#  end

############################################################################################

  def enable_loading_panel
    h = javascript_tag do
        "Ajax.Responders.register({
            onCreate: function(){ $('loading_panel').style.visibility='visible'; },
            onComplete: function(){ decoGreyboxLinks();
                                    $('loading_panel').style.visibility='hidden'; }
        });"
    end
    h += content_tag :div, :id => 'loading_panel' do
        r = image_tag("spinner.gif", :class => "loading_spinner")
        r += " "
        r += _("Loading")
        r += "..."
    end
    h
  end

############################################################################################

  def extjs_model_tree
    html = ""
    html += stylesheet_link_tag "/javascripts/ext/resources/css/ext-all.css"
    html += javascript_include_tag "/javascripts/ext/adapter/prototype/ext-prototype-adapter.js"
    html += javascript_include_tag "/javascripts/ext/ext-all.js"
    html += content_tag :style, :type => "text/css" do
      "
      .x-tree .x-panel-body {
        background-color: transparent;
      }
      .x-tree-node .x-tree-node-over {
        background-color: #CCCCCC;
      }
      "
    end

    # TODO 04** prevent render modal layout inside another modal layout
    filter_params = request.path_parameters.keys << "category_id"
    parameters = ""
    params.each {|k,v| parameters += ", #{k}: '#{v}'" unless filter_params.include?(k) }

    html += javascript_tag do
      "
      start = function(){
  
      // create initial root node
        var categories_root = new Ext.tree.AsyncTreeNode({
          text: '#{_("All")}',
          id:'ynode-0',
      leaf: false,
      real_id: '0'
        });
      
      var categories_loader = new Ext.tree.TreeLoader({
        url:'/categories.ext_json',
        requestMethod:'GET'
      });
  
      categories_loader.on('beforeload', function(treeLoader, node) {
          treeLoader.baseParams.category_id = (node.attributes.real_id ? node.attributes.real_id : 0);
        }, this);
          
      // create the tree
        var categories_panel = new Ext.tree.TreePanel({
          loader: categories_loader,
      title: '#{_("Categories")}',
      collapsible: false,
      border: false,
      animate:true,
      autoScroll:true,
          root: categories_root,
          rootVisible:true,
      renderTo: 'categories',
      hlColor: '#FF0000',
      listeners: {
        click: function( node, e ){
          if(node.attributes.real_id != 0) node.toggle();
          new Ajax.Updater('list_table', '', {asynchronous:true, evalScripts:true, method:'get', onLoading:function(request){Element.show('spinner')}, parameters: {category_id: node.attributes.real_id #{parameters}}}); return false;
        }
      }
        });
      
      // expand invisible root node to trigger load
        // of the first level of actual data
        categories_root.expand();
      };
  
    Ext.onReady(start);
    "
    end
    return html
  end

############################################################################################

  def time_line(lines, write_start = true, write_end = true)
    html = ""
    
    d1 = Array.new
    d2 = Array.new
      
    lines.each do |l|
          d1 << l.start_date
          d2 << l.end_date
          
      html += "
        Quantity: #{l.quantity}
        <br />      
        Model: #{l.model.name}
        <br />
        #{dates_with_period(l.start_date, l.end_date)}
        <hr />
      "
    end
    
    html += form_tag( { :lines => lines }, :name => "f", :target=> '_top' )
      f = ""
      f += "Start: "
      f += date_select("line", "start_date", { :default => d1.min, :order => [:day, :month, :year] }, { :onchange => "validate_date_sequence();", :disabled => !write_start })
    
      f += " - End: "
      f += date_select("line", "end_date", { :default => d2.max, :order => [:day, :month, :year] }, { :onchange => "validate_date_sequence();", :disabled => !write_end })
      
      f += "<br/><br/><div id='select_notice' class='flash_notice'></div><br />"
      
      if lines.length == 1
      
      f += "<table class='availability_overview'>
          <tr class='availability'>
          <td>#{_("Month")}</td>"
          1.upto(31) do |i|
            f += "<td>#{i}</td>"
          end
        f += "</tr>"
        
          l = lines.first

          # TODO 1202** 
#          d = l.max_end_date
#          f += "Max extend until #{d}" if d

          current_date = Date.today
          availability = l.model.available_dates_for_document_line(current_date.beginning_of_month, (current_date + 6.month).end_of_month, l, current_date.beginning_of_month)
          last_quantity = -1
          availability.each do |a| 
            f += "<tr class='availability'><td>#{a[0].strftime('%B')}" if 1 == a[0].day
              if a[0] < current_date
                f += "<td></td>"
              else
                  color = a[1]
                  color = 0 if color < 0
                  color = 5 if color > 5
        
                  c = "with_tooltip available_" + color.to_s + " selectable_date"
                  c += " selected_date" if a[0].between?(d1.min, d2.max)
                  c += " selected_date_start" if a[0].eql?(d1.min)
                  c += " selected_date_end" if a[0].eql?(d2.max)
  
               f += "<td id='#{a[0].strftime('%Y%m%d')}' title='#{a[0].strftime('%d.%m.%Y')}' class='#{c}' 
                      onclick='changeDate(#{a[0].year}, #{a[0].month}, #{a[0].day});'
                      onmouseover=\"this.addClassName('selectable_date_over');\"
                      onmouseout=\"this.removeClassName('selectable_date_over');\">"
               f += "#{a[1]}" if a[1] != last_quantity
               f += "</td>"
               
                last_quantity = a[1]
              end
            f +="</tr>" if a[0].end_of_month == a[0]
          end
      f += "</table>"
      end
  
      f += "<br /><div id='error' class='flash_error' style='display:none;'>#{_("Start Date must be before End Date")}</div>
            <br />
            <div class='buttons'>"
      f += submit_button(_("Confirm"),
                        :icon => "date_edit",
                        :class => 'negative',
                        :id => 'submit_button' )
                 
      f += cancel_popup_button(_("Cancel") )
      f += "</div>"  
    
    html += f
    html += "</form>"

    html += javascript_tag do
      "
      var clicks = 0;
      var write_start = #{write_start};
      var write_end = #{write_end};
      var write_dates = new Array();
      if (write_start) write_dates.push('start');
      if (write_end) write_dates.push('end');
      
      function toggle_select_notice(){
        if(write_dates.length){
          $('select_notice').innerHTML = 'Select ' + write_dates[clicks % write_dates.length] + ' date';
          new Effect.Highlight('select_notice');
        }
      }
      
      function validate_date_sequence(){
        var start_date = $('line_start_date_1i').value * 10000 + $('line_start_date_2i').value * 100 + $('line_start_date_3i').value * 1;
        var end_date = $('line_end_date_1i').value * 10000 + $('line_end_date_2i').value * 100 + $('line_end_date_3i').value * 1;
        
        if(end_date < start_date){
          $('submit_button').fade();
          $('error').appear();
          new Effect.Highlight('error');
        }else{
          $('submit_button').appear();
          $('error').fade();
        }
      }
  
      
      function changeDate(y, m, d){
        if(write_dates.length){
          var type = write_dates[clicks % write_dates.length];
          
          $('line_' + type + '_date_1i').value = y;
          $('line_' + type + '_date_2i').value = m;
          $('line_' + type + '_date_3i').value = d;
          
          clicks++;
          toggle_select_notice();
          validate_date_sequence();

          // TODO 
          //Element.removeClassName('20080911', 'selected_date');
          //Element.addClassName('20080911', 'selected_date');
        }
      }
      
      toggle_select_notice();
      "
    end
    
    html
  end

end
