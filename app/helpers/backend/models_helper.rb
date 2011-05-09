module Backend::ModelsHelper

  # creates a javascript widget that displays the
  # availability and allocation of a model over time
  #
  def timeline(model, inventory_pool)
    set_timeline_headers()
    
    partition = model.partitions.in(inventory_pool).current_partition
    changes = model.availability_changes_in(inventory_pool).changes

    # events represent the horizontal bars in Timeline
    # that display how long an item is lent out
    events = {}
    events = reservations_to_events( model.running_reservations(inventory_pool))

    # TODO dynamic timeZone, get rid of GMT in the bubble
    sum_w = 35

    # bands represent the horizontal bands inside Timeline. The first band is
    # the scrollable "top" "month" band, the next one is the "General Group"
    # band and then follow other groups that exist within an inventory pool
    #
    # bandNames contains the names of the bands starting with the "month" band
    bandNames_js = [""]

    # bandInfos contains JS initialisation code for Timeline bands
    #
    #bandInfos_js = ["Timeline.createBandInfo({ eventSource: eventSource[-1], overview: true, width: '#{sum_w}px', intervalUnit: Timeline.DateTime.MONTH, intervalPixels: 100, align: 'Top' })"]
    bandInfos_js = [ <<-BAND1
      Timeline.createBandInfo( { timeZone:       2,
                                 overview:       true,
                                 intervalUnit:   Timeline.DateTime.MONTH,
                                 intervalPixels: 100,
                                 align:          'Top',
                                 theme:          theme })
     BAND1
    ]
    # TODO total overview # bandInfos_js << "Timeline.createBandInfo({ timeZone: 2, overview: true, width: '#{sum_w}px', intervalUnit: Timeline.DateTime.DAY, intervalPixels: 32, align: 'Top', theme: theme })"

    # decorators are specially marked days inside a bar, which in leihs will display
    # the available items inside a group on a certain day. We only display available
    # numbers of items on days where the numbers change 
    decorators_js = [""]
    partition.keys.sort {|a,b| a.to_i <=> b.to_i }.each do |g| # the to_i comparison is needed to convert nil to 0
      group_id = g.to_i
      # count = partition[g]
      next unless events.keys.include?(group_id)
      #w = [0, count].max * 40 + 40 # TODO get max out_quantity among all changes
      #sum_w += w
      bandInfos_js << <<-BAND2
        Timeline.createBandInfo( { timeZone:       2,
                                   eventSource:    eventSource[#{group_id}],
                                   intervalUnit:   Timeline.DateTime.DAY,
                                   intervalPixels: 70,
                                   align:         'Top',
                                   theme:         theme } )
        BAND2
      bandNames_js << (group_id > 0 ? inventory_pool.groups.find(group_id).to_s : _("General"))
      
      prev_in_quantity = nil
      decorators_js << changes.collect do |change|
        d = []
        in_quantity = change.in_quantity_in_group(g)
        if in_quantity < 0 or change.quantities.collect(&:in_quantity).sum < 0
          d << <<-BAND3
               new Timeline.SpanHighlightDecorator(
                     { startDate: '#{change.start_date.to_time.to_s(:rfc822)}',
                       endDate:   '#{changes.end_date_of(change).tomorrow.to_time.to_s(:rfc822)}',
                       color:     '#f00',
                       opacity:   50 } )
               BAND3
        end
        if prev_in_quantity != in_quantity
          prev_in_quantity = in_quantity
          d << <<-BAND4
               new Timeline.SpanHighlightDecorator(
                     { startDate: '#{(change.start_date.to_time - 1.hour).to_s(:rfc822)}',
                       endDate:   '#{(change.start_date.to_time + 1.hour).to_s(:rfc822)}',
                       color:     '#555555',
                       opacity:   50,
                       endLabel:  '#{in_quantity}' } )
               BAND4
        end
        (d.empty? ? nil : d.join(', '))
      end.compact
    end

    # TODO automatic autowidth
    r = javascript_tag do
      <<-HERECODE
      window.jQuery = SimileAjax.jQuery;

      var eventSource = [];
      var events = #{events.to_json};
      for( var group_id in events) {
        eventSource[group_id] = new Timeline.DefaultEventSource();
        eventSource[group_id].loadJSON({events: events[group_id]}, document.location.href);
      }

      jQuery(document).ready(function($) {

        var theme = Timeline.ClassicTheme.create();
        theme.firstDayOfWeek = 1;
        theme.autoWidth = true;
        theme.event.track.autoWidthMargin = 1.0;
        theme.event.track.offset = 60;
        theme.event.track.gap = -13;
        theme.event.overviewTrack.offset = #{sum_w};
        theme.event.tape.height = 15;
        
        var bandNames = #{bandNames_js.to_json};
        
        var bandInfos = [
            #{bandInfos_js.join(',')}
        ];
        
        bandInfos[0].highlight = true;

        for (var i = 0; i < bandInfos.length; i++) {
          if(bandInfos.length > 1 && i != 1) bandInfos[i].syncWith = 1;
          bandInfos[i].decorators = [
              new Timeline.SpanHighlightDecorator({
                  startDate:  "#{(Date.today.to_time - 1.hour).to_s(:rfc822)}",
                  endDate:    "#{(Date.tomorrow.to_time - 1.hour).to_s(:rfc822)}",
                  color:      "#1f71d7",
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

        var tl = Timeline.create(document.getElementById("my_timeline"), bandInfos);
        tl.layout();
      });
      HERECODE
    end
    
    r += content_tag :div, :id => "my_timeline", :style => "height: #{sum_w}px; border: 1px solid #aaa" do end
  end

###########################################################################

private

  def set_timeline_headers()
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
      r += stylesheet_link_tag 'timeline'
    end
  end

  # iterate through model reservations and prepare necessary parameters
  # to construct events inside with Timeline
  def reservations_to_events( running_reservations )
    events = {}
    running_reservations.each do |line|
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

      events[group_id] ||= []
      events[group_id] << {:start         => line.start_date.to_time.to_s(:rfc822),
                           :end           => (line.end_date.tomorrow.to_time - 1.second).to_s(:rfc822),
                           :durationEvent => true,
                           :title         => event_title(line),
                           :description   => event_description(line),
                           #:trackNum     => (events[group_id].empty? ? 0 : (line.item ? events[group_id].collect {|e| e[:trackNum] }.compact.max.to_i.next : nil)),
                           :color         => color,
                           :textColor     => 'black',
                           :classname     => (!line.item and !line.available? ? "unavailable" : nil) }
    end
    events
  end

  def event_title(line)
      extra_info = line.item.try(:inventory_code) || _("Quantity: %d") % line.quantity
      return "#{line.document.user} (#{extra_info})"
  end

  # construct the popup that is being displayed when you click on
  # an event
  def event_description(line)

      link_string, link_path =
        if line.is_a?(OrderLine)
          [ icon_tag("accept") + _("Acknowledge"),
            backend_inventory_pool_user_acknowledge_path(current_inventory_pool, line.document.user, line.document) ]
        elsif line.document.status_const == Contract::UNSIGNED
          [ icon_tag("arrow_turn_right") + _("Hand Over"),
            backend_inventory_pool_user_hand_over_path(current_inventory_pool, line.document.user) ]
        else
          [ icon_tag("arrow_undo") + _("Take Back"),
            backend_inventory_pool_user_take_back_path(current_inventory_pool, line.document.user) ]
        end
 
      document_link = content_tag :div, :class => "buttons", :style => "margin: 1.5em;" do
                        link_to link_string, link_path
                      end
      return "Group: #{line.allocated_group}<br />Phone: #{line.document.user.phone}<br />#{document_link}"
  end
end
