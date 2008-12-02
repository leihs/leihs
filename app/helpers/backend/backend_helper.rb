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
#          r = form_tag :url => { }, :method => :get do
          r = "<form action=\"\">"
            filter_params = request.path_parameters.keys << "query"
            params.each {|k,v| r += hidden_field_tag(k, v) unless filter_params.include?(k) }

            r += text_field_tag :query, query, :onchange => "submit()", :id => 'search_field'
            r += javascript_tag("$('search_field').focus()")
            
            r += content_tag :div, :class => "result" do
              total = (records.is_a?(ActsAsFerret::SearchResults) ? records.total_hits : records.total_entries)
              s = " <b>#{total}</b> results"
              s += " for <b>#{query}</b>" if query
              s += " filtering <b>#{filter}</b>" if filter
              w = will_paginate(records, :params => {:query => query})
              s += w if w
              s
            end
          r += "</form>"
#          end
          r
      end
  end 


  def table_tag(options = {}, html_options = {}, &block)
#    tag(:table, html_options, true)

    html = '<table>'
    
    html += content_tag :tr do
      r = ""
      options[:columns].each do |column|
        r += content_tag :th do
           column
        end
      end
      r
    end

    options[:records].each do |record|
      html += capture(record, &block)
#      yield(record)
    end
        
    html += '</table>'
#    concat(html, block.binding)
    return html
  end


  # TODO 17** buttons_tag
  # <div class="buttons" onclick="if(event.target.hasClassName('ghosted')){ return false; }">

  # TODO 17** ghosted buttons are not preventing right click (open link in New Window, etc)

end
