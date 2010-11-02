module Backend::ModelsHelper
  
  def timeline(model, inventory_pool)
    content_for :head do
      r = javascript_tag do
        <<-HERECODE
          Timeline_ajax_url='/javascripts/simile_timeline/timeline_ajax/simile-ajax-api.js';
          Timeline_urlPrefix='/javascripts/simile_timeline/timeline_js/';
          Timeline_parameters='bundle=true&forceLocale=#{locale.language}';
        HERECODE
      end
      r += javascript_include_tag "simile_timeline/timeline_js/timeline-api.js"
      r += javascript_tag do
        "SimileAjax.History.enabled = false;"
      end
      r += content_tag :style do
        <<-HERECODE
          #my_timeline table tr {
            background: none;
            border: none;
          }
          #my_timeline table tr td {
            vertical-align: top;
            padding-top: 30px;
            font-size: 0.8em;
            color: #555555;
          }
          #my_timeline .timeline-ether-highlight {
            background-color: #98d9e7;
          }
          #my_timeline .timeline-event-label {
            padding-top: 0.2em;
            padding-left: 0.2em;
          }
          #my_timeline .tape-unavailable {
            border: 1px solid red;
          }
        HERECODE
      end
    end

    events = {}
    changes = model.availability_changes.in(inventory_pool)
    partition = changes.current_partition

    model.running_reservations(inventory_pool).each do |line|
      color = if not line.item
                '#90c1c8'
              elsif line.is_late?
                'red'
              elsif line.returned_date
                '#e1e157'
              else
                '#e3aa01'
              end
      group_id = line.allocated_group.try(:id).to_i
      title = "#{line.document.user} (#{line.item.try(:inventory_code) || _("Quantity: %d") % line.quantity})"
      link_string, link_path = if line.is_a?(OrderLine)
                                 [icon_tag("accept") + _("Acknowledge"), backend_inventory_pool_user_acknowledge_path(current_inventory_pool, line.document.user, line.document)]
                               elsif line.document.status_const == Contract::UNSIGNED
                                 [icon_tag("arrow_turn_right") + _("Hand Over"), backend_inventory_pool_user_hand_over_path(current_inventory_pool, line.document.user)]
                               else
                                 [icon_tag("arrow_undo") + _("Take Back"), backend_inventory_pool_user_take_back_path(current_inventory_pool, line.document.user)]
                               end
      document_link = content_tag :div, :class => "buttons", :style => "margin: 1.5em;" do
                        link_to link_string, link_path
                      end
      description = "Group: #{line.allocated_group}<br />Phone: #{line.document.user.phone}<br />#{document_link}"
      events[group_id] ||= []
      events[group_id] << {:start => line.start_date.to_time.rfc2822, :end => (line.end_date.tomorrow.to_time - 1.second).rfc2822, :durationEvent => true,
                           :title => title, :description => description, #:trackNum => (events[group_id].empty? ? 0 : (line.item ? events[group_id].collect {|e| e[:trackNum] }.compact.max.to_i.next : nil)),
                           :color => color, :textColor => 'black', :classname => (!line.item and !line.available? ? "unavailable" : nil) }
    end

    #eventSource_js = ["eventSource[-1] = new Timeline.DefaultEventSource(); eventSource[-1].loadJSON(#{{:events => events.values.flatten}.to_json}, document.location.href);"]
    eventSource_js = []
    events.each_pair do |group_id, event|
      json = {:events => event}.to_json 
      eventSource_js << "eventSource[#{group_id}] = new Timeline.DefaultEventSource(); eventSource[#{group_id}].loadJSON(#{json}, document.location.href);"
    end

    # TODO dynamic timeZone, get rid of GMT in the bubble
    sum_w = 35
    #bandInfos_js = ["Timeline.createBandInfo({ eventSource: eventSource[-1], overview: true, width: '#{sum_w}px', intervalUnit: Timeline.DateTime.MONTH, intervalPixels: 100, align: 'Top' })"]
    bandInfos_js = ["Timeline.createBandInfo({ timeZone: 2, overview: true, width: '#{sum_w}px', intervalUnit: Timeline.DateTime.MONTH, intervalPixels: 100, align: 'Top', theme: theme })"]
    # TODO total overview # bandInfos_js << "Timeline.createBandInfo({ timeZone: 2, overview: true, width: '#{sum_w}px', intervalUnit: Timeline.DateTime.DAY, intervalPixels: 32, align: 'Top', theme: theme })"
    bandNames_js = [""] #_("Months")
    decorators_js = [""]
    partition.keys.sort {|a,b| a.to_i <=> b.to_i }.each do |k| # the to_i comparison is needed to convert nil to 0
      group_id = k.to_i
      count = partition[k]
      next unless events.keys.include?(group_id)
      w = [0, count].max * 40 + 40 # TODO get max out_quantity among all changes
      sum_w += w
      bandInfos_js << "Timeline.createBandInfo({ timeZone: 2, eventSource: eventSource[#{group_id}], width: '#{w}px', intervalUnit: Timeline.DateTime.DAY, intervalPixels: 32, align: 'Top', theme: theme })"
      bandNames_js << (group_id > 0 ? inventory_pool.groups.find(group_id).to_s : "")
      
      prev_in_quantity = nil
      decorators_js << changes.collect do |change|
        d = []
        in_quantity = change.in_quantity_in_group(k)
        if in_quantity < 0 or change.quantities.sum(:in_quantity) < 0
          d << "new Timeline.SpanHighlightDecorator({ startDate: '#{change.start_date.to_time.rfc2822}', endDate: '#{change.end_date.tomorrow.to_time.rfc2822}', color: '#f00', opacity: 50 })"
        end
        if prev_in_quantity != in_quantity
          prev_in_quantity = in_quantity
          d << "new Timeline.SpanHighlightDecorator({ startDate: '#{change.start_date.to_time.rfc2822}', endDate: '#{(change.start_date.to_time + 2.hours).rfc2822}', color: '#555555', opacity: 50, endLabel: '#{in_quantity}' })"
        end
        (d.empty? ? nil : d.join(', '))
      end.compact
    end

    # TODO automatic autowidth
    r = javascript_tag do
      <<-HERECODE
      window.jQuery = SimileAjax.jQuery;

      var eventSource = [];
      #{eventSource_js.join}

      jQuery(document).ready(function($) {

        var theme = Timeline.ClassicTheme.create();
        theme.firstDayOfWeek = 1;
        theme.autoWidth = true;
        theme.event.track.autoWidthMargin = 1.0;
        theme.event.track.offset = 60;
        theme.event.track.gap = -10;
        theme.event.overviewTrack.offset = 35;
        theme.event.tape.height = 18;
        
        var bandNames = #{bandNames_js.to_json};
        
        var bandInfos = [
            #{bandInfos_js.join(',')}
        ];
        
        bandInfos[0].highlight = true;

        for (var i = 0; i < bandInfos.length; i++) {
          if(i != 1) bandInfos[i].syncWith = 1;
          bandInfos[i].decorators = [
              new Timeline.SpanHighlightDecorator({
                  startDate:  "#{Date.today.to_time.rfc2822}",
                  endDate:    "#{Date.tomorrow.to_time.rfc2822}",
                  color:      "#98d9e7",
                  opacity:    50,
                  startLabel: bandNames[i]
              })
          ];
        }
        
        #{dec = ""
        decorators_js.each_with_index do |d,i|
          next if d.blank?
          dec << "bandInfos[#{i}].decorators = bandInfos[#{i}].decorators.concat([#{d.join(', ')}]); "
        end
        dec}

        Timeline.create(document.getElementById("my_timeline"), bandInfos);
      });
      HERECODE
    end
    
    r += content_tag :div, :id => "my_timeline", :style => "height: #{sum_w}px; border: 1px solid #aaa" do end
  end
  
end
