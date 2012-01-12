module Backend::BackendHelper
  
  def last_visitors
    #TODO: last visitors should be scoped through inventory_pool and later through selected day in daily view
    #TODO: move this inside of the inventory pools model ?
    return false if session[:last_visitors].blank?
    session[:last_visitors] = session[:last_visitors][0..3]
    session[:last_visitors].map { |x| link_to x.second, user_path(x.first) }.join(", ")
  end
  
  def is_current_page?(section)
    
    #TODO: PREVENT LOOPING
    # return false if caller == is_current_page?(section)
    
    case section
      when "daily"
        current_page?(backend_inventory_pool_path(current_inventory_pool))
      when "orders"
        current_page?(:controller => "backend/orders") ||
        !!(request.path =~ /acknowledge\/\d+$/)
      when "search"
        current_page?(:controller => "backend", :action => :search)
      when "hand_over"
        current_page?(:controller => "backend/hand_over")
      when "take_back"
        current_page?(:controller => "backend/take_back")
      when "contracts"
         current_page?(:controller => "backend/contracts")
      when "visits"
         current_page?(:controller => "backend/visits")
      when "lending"
        is_current_page?("daily") or
        is_current_page?("orders") or
        is_current_page?("hand_over") or
        is_current_page?("take_back") or
        is_current_page?("contracts") or
        is_current_page?("visits")
    end
  end
  
# EVERYTHING AFTER HERE IS OLD STUFF
=begin
  def table(options = {}, html_options = {}, &block)
    table_tag(options, html_options, &block)
  end

  def table_with_search_and_pagination(options = {}, html_options = {}, &block)
    capture_haml do
      haml_tag :div, :class => "table-overview", :id => 'list_table' do
        haml_concat controller_bar(options[:records], true, options[:with_cvs_export] || false)
        haml_concat table_tag(options, html_options, &block)
        haml_concat controller_bar(options[:records])
      end
    end
  end 

  def controller_bar(records, with_search_field = false, with_cvs_export = false, query = params[:query], filter = params[:filter])
    query = nil if query.blank?

    capture_haml do
      haml_tag :div, :class => "table-overview controller" do
        filter_params = request.path_parameters.keys << "query" << "page"
        parameters = ""
        params.each {|k,v| parameters += ", #{k}: '#{v}'" unless filter_params.include?(k) }
        
        if with_search_field
          # evalJS must be set, since we are updating the page parts via JS - see models/index.js.rjs 
          haml_concat text_field_tag :query, query, :id => 'search_field',
                              :onchange => "new Ajax.Request('', {asynchronous:true, evalJS:true, method:'get', " \
                                                                 "parameters: {query: this.value #{parameters}}});" \
                                           "return false;" # TODO move to application.js                              
        end
        
        haml_tag :div, :class => "result", :style => "min-height: 200px;" do
          haml_concat _(" <b>%d</b> results") % records.total_entries
          haml_concat _(" for <b>%s</b>") % query if query
          haml_concat _(" filtering <b>%s</b>") % filter if filter
          w = will_paginate records, :previous_label => _("Previous"), :next_label => _("Next")
          haml_concat w if w
        end
        
        haml_tag :div, :class => "csv_export buttons" do
          link_to "CSV export", { :controller => :items, :action => :index, :query => query, :filter => filter, :format => :csv }
        end if with_cvs_export
      end
    end
  end 


  def table_tag(options = {}, html_options = {}, &block)
    capture_haml do
      haml_tag :table do
        haml_tag :tr do
          options[:columns].each do |column|
            haml_tag :th do
              if column.is_a?(Array)
                b = (params[:sort] == "#{column[1]}_sort") # TODO 0501 why _sort ??
                sort_mode = (params[:sort_mode] == :asc ? :desc : :asc) if b
                haml_concat link_to column[0], params.merge({ :sort => column[1], :sort_mode => sort_mode, :page => 1}), :remote => true
                haml_concat icon_tag("arrow_" + (params[:sort_mode] == :asc ? "down" : "up")) if b
              else
                haml_concat column
              end
            end
          end
        end unless options[:columns].blank?
    
        records = (options[:reorder] ? options[:reorder].call(options[:records].to_a) : options[:records])
        records.each do |record|
          haml_concat capture(record, &block)
        end
      end
    end
  end

  def reorder_inventory_pools(records)
    records.partition {|ip| is_apprentice?(ip) }.flatten  
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
          r += greybox_link_to_page(user.name,
                    backend_inventory_pool_user_path(current_inventory_pool, user, :layout => "modal"),
                    :title => _("User"),
                    :class => "iconized-notxt edit-user" )
          r += tag :br
          r += render :partial => 'backend/users/resume'
          r
        end
      end
    end
  end
    

############################################################################################

  def show_line_model(model)
    html = greybox_link_to_page(model.name,
            backend_inventory_pool_model_path(current_inventory_pool, model, :layout => "modal"),
            :title => _("Model"),
            :class => "thickbox iconized-notxt edit-package" )

    html += content_tag :ul, :class => "model_group" do
      r = "".html_safe
      model.package_models.each do |model|         
        r += content_tag :li do
          model.name
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

  def time_line(lines, write_start = true, write_end = true)
    html = ""
    summary = ""
    
    d1 = Array.new
    d2 = Array.new
    unavailable_periods = []
      
    lines.each do |l|
      d1 << l.start_date
      d2 << l.end_date
      unavailable_periods += l.unavailable_periods unless l.is_a?(OptionLine)
          
      summary += content_tag :div, :style => "padding: 1em; border-bottom: 1px solid grey;" do
        "Quantity: #{l.quantity} - Model: #{l.model.name}
        <br />
        #{dates_with_period(l.start_date, l.end_date)}"
      end
    end

    html += form_tag( { :lines => lines }, :name => "f", :target=> '_top' )
      f = content_tag :table do
        content_tag :tr do
          r = content_tag :td, :class => "date_select" do
            s = content_tag :b do
              "#{_('Start')}: "
            end
            s += content_tag :span, :id => 'start_weekday' do
            end
            s += "<br/>"
            s += date_select :line, :start_date, { :default => d1.min, :order => [:day, :month, :year] }, { :onchange => "validate_date_sequence();", :disabled => !write_start }
          end
          r += content_tag :td, :class => "date_select" do
            s = content_tag :b do
              "#{_('End')}: "
            end
            s += content_tag :span, :id => 'end_weekday' do
            end
            s += "<br/>"
            s += date_select :line, :end_date, { :default => d2.max, :order => [:day, :month, :year] }, { :onchange => "validate_date_sequence();", :disabled => !write_end }
          end
          r += content_tag :td, :class => 'buttons', :style => "width: 30%;" do
            s = submit_button _("Confirm"),
                              :icon => "date_edit",
                              :class => 'negative',
                              :id => 'submit_button'
            #old# s += cancel_popup_button _("Cancel")
            s += content_tag :span, :id => 'error_end_before_start', :style => 'display:none; color: red; font-weight: bold;' do
              _("Start Date must be before End Date") + "<br />"
            end
            s += content_tag :span, :id => 'error_too_early',        :style => 'display:none; color: red; font-weight: bold;' do
              _("You can't have a Start Date before today") + "<br />"
            end
          end
          r
        end
      end
        
#      if lines.length == 1 and (lines.first.is_a?(ItemLine) or lines.first.is_a?(OrderLine))
#        line = lines.first
      
        months = 12
        bound_start_date = Date.today.beginning_of_month
        bound_end_date = months.months.from_now.to_date.end_of_month
        f += datepicker(months)
        
        f += javascript_tag do
          j = "$$('.datepicker_date').each(function(element) {
                  element.addClassName('selectable_date');
                });"


          unavailable_periods.each do |u|
            ([u.start_date, bound_start_date].max..[u.end_date, bound_end_date].min).each do |d|
              d = d.to_formatted_s(:db)
              j += "if($('#{d}')){
                      $('#{d}').removeClassName('selectable_date');
                      $('#{d}').addClassName('available_0');
                    }"
            end
          end
          
          j += "$$('.selectable_date').each(function(element) {
                  element.observe('click', function(event){
                    changeDate(event.target.id);
                  });
                });"
          j
        end
        

    html += f
    html += "</form>"
    html += summary

    html += javascript_tag do
      "
      Date.prototype.to_formatted_s_db = function () {
        y = this.getFullYear();
        m = this.getMonth() + 1;
        d = this.getDate();
        return [y, m > 9 ? m : '0' + m, d > 9 ? d : '0' + d].join('-')
      }
      
      var clicks = 0;
      var write_start = #{write_start};
      var write_end = #{write_end};
      var write_dates = new Array();
      if (write_start) write_dates.push('start');
      if (write_end) write_dates.push('end');
      
      function toggle_select_notice(){
        if(write_dates.length){
          new Effect.Highlight(write_dates[clicks % write_dates.length] + '_weekday');
        }
      }
      
      Date.prototype.daystart = function( ){
        var _daystart = new Date(this.getTime());
        _daystart.setHours(0);
        _daystart.setMinutes(0);
        _daystart.setSeconds(0);
        _daystart.setMilliseconds(0);

        return _daystart;
      }

      function validate_date_sequence(){
        var today = new Date();
        var start_date = new Date($('line_start_date_1i').value, $('line_start_date_2i').value - 1, $('line_start_date_3i').value);
        var end_date   = new Date($('line_end_date_1i').value,   $('line_end_date_2i').value   - 1, $('line_end_date_3i').value);
        var formatted_start_date = start_date.to_formatted_s_db();
        var formatted_end_date = end_date.to_formatted_s_db();

        var weekday = new Array('#{_('Sunday')}','#{_('Monday')}','#{_('Tuesday')}','#{_('Wednesday')}','#{_('Thursday')}','#{_('Friday')}','#{_('Saturday')}')
        $('start_weekday').update(weekday[start_date.getDay()]);
        $('end_weekday').update(weekday[end_date.getDay()]);

        write_dates.each(function(type){
          $$('.selected_date_' + type).each(function(element) {
            element.removeClassName('selected_date_' + type);
          });
        });
        if($(formatted_start_date)) $(formatted_start_date).addClassName('selected_date_start');
        if($(formatted_end_date)) $(formatted_end_date).addClassName('selected_date_end');
        // TODO validate dropdown selection

        if(end_date < start_date){
          $('submit_button').hide();
          $('error_end_before_start').show();
        }else if(#{write_start} && (start_date < today.daystart()) ){
          $('submit_button').hide();
          $('error_too_early').show();
        }else{
          $('submit_button').show();
          $('error_end_before_start').hide();
          $('error_too_early').hide();
        }
      }
  
      
      function changeDate(date){
        date_array = date.split('-');
        
        if(write_dates.length){
          var type = write_dates[clicks % write_dates.length];
          
          $('line_' + type + '_date_1i').value = parseInt(date_array[0], 10);
          $('line_' + type + '_date_2i').value = parseInt(date_array[1], 10);
          $('line_' + type + '_date_3i').value = parseInt(date_array[2], 10);
          
          clicks++;
          toggle_select_notice();
          validate_date_sequence();
        }
      }
      
      toggle_select_notice();
      validate_date_sequence();
      "
    end
    
    html
  end

  def datepicker(months)
    content_tag :table, :class => 'availability_overview' do
      tr = content_tag :tr, :class => 'availability' do
        th = content_tag :th do
          _("Month")
        end
        1.upto(31) do |i|
          th += content_tag :th, :style => "min-width: 2em; padding: 0; text-align: center;" do
                  i
                end
        end
        th
      end

      months.times do |i|
        start_date = i.months.from_now.to_date.beginning_of_month
        end_date = i.months.from_now.to_date.end_of_month

        tr += content_tag :tr, :class => 'availability' do
                td = content_tag :th do
                  start_date.to_formatted_s(:month_and_year)
                end
                (start_date..end_date).each do |d|
                  style = (current_inventory_pool.is_open_on?(d) ? nil : "background-color: grey;") if current_inventory_pool
                  td += content_tag :td, :id => d.to_formatted_s(:db),
                                         :title => d.to_formatted_s(:with_weekday_name),
                                         :class => "datepicker_date",
                                         :style => style do end
                end
                (31-end_date.day).times do
                  td += content_tag :td, :class => "datepicker_nodate" do end
                end
                td
              end
      end
      tr
    end
  end
  
############################################################################################

  def select_tag_for_buildings(selected = nil)
    select_tag 'location[building_id]', "<option value=''>#{_("None")}</option>" + options_from_collection_for_select(Building.all, :id, :to_s, selected)
  end

############################################################################################

  def lines_preview(document)
    s = 3
    lines = document.lines
    r = Array.new
    
    lines[0..s-1].each do |l|
      str = l.model.name
      str += " (#{l.item.inventory_code})" unless (l.item.nil? or l.item.inventory_code.blank?)
      r << str
    end
    r << "..." if lines.size > s
    r.join(', ')
  end

  def lines_summary(lines)
    content_tag :table do
      s = ""
      lines.each do |l|
        s += content_tag :tr do
          r = ""
          permission_needed = (l.item and l.item.needs_permission?)
          r += content_tag :td, :style => "text-align: right;" do
            l.quantity
          end
          r += content_tag :td, :class => "#{permission_needed ? "closed" : ""}" do
            w = ""
            if permission_needed
              w += _("Permission needed:")
              w += "<br />"
            end
            w += "#{l.model.name}<br />"
            w += content_tag :div, :class => 'hand_over_note' do
              "#{l.model.hand_over_note}"
            end if l.class.name == "ItemLine" and not l.model.hand_over_note.blank?
            w
          end
          r += content_tag :td do
            l.item.inventory_code
          end unless l.item.nil?
          r += content_tag :td do
            dates_with_period(l.start_date, l.end_date)
          end
          r
        end
      end
      s
    end
  end

=end

end