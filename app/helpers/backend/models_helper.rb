module Backend::ModelsHelper
  
  def timeline(model, inventory_pool)
    content_for :head do
      r = javascript_tag do
        p = "Timeline_ajax_url='/javascripts/simile_timeline/timeline_ajax/simile-ajax-api.js';"
        p += "Timeline_urlPrefix='/javascripts/simile_timeline/timeline_js/';"       
        p += "Timeline_parameters='bundle=true';"
      end
      r += javascript_include_tag "simile_timeline/timeline_js/timeline-api.js"
      r += content_tag :style do
        <<-HERECODE
          #my_timeline table tr {
            background: none;
            border: none;
          }
        HERECODE
      end
    end

    events = {}
    partition = model.availability_changes.in(inventory_pool).current_partition #.sort {|a,b| a.first.to_i <=> b.first.to_i }

    bandInfos_js = []
    bandNames_js = []
    partition.each_pair do |group_id, count|
      group_id = group_id.to_i
      events[group_id] = []
      bandInfos_js << "Timeline.createBandInfo({ eventSource: eventSource[#{group_id}], width: '#{count * 40 + 40}px', intervalUnit: Timeline.DateTime.DAY, intervalPixels: 50, theme: theme })"
      bandNames_js << (group_id > 0 ? inventory_pool.groups.find(group_id).to_s : "")
    end

    model.running_reservations(inventory_pool).each do |line|
      color = if not line.item
                'grey'
              elsif line.is_late?
                'red'
              elsif line.returned_date
                '#e1e157'
              else
                '#e3aa01'
              end
      group_id = line.allocated_group.try(:id).to_i
      title = "#{line.document.user}"
      title += " (#{line.item.inventory_code})" if line.item
      events[group_id] << {:start => line.start_date, :end => line.end_date, :durationEvent => true,
                           :title => title, :description => "Group: #{line.allocated_group}",
                           :color => color, :textColor => 'black' }
    end

    eventSource_js = []
    events.each_pair do |group_id, event|
      json = {:events => event}.to_json
      eventSource_js << "eventSource[#{group_id}] = new Timeline.DefaultEventSource(); eventSource[#{group_id}].loadJSON(#{json}, document.location.href);"
    end

    r = javascript_tag do
      <<-HERECODE
      window.jQuery = SimileAjax.jQuery;

      var eventSource = [];
      #{eventSource_js.join}

      jQuery(document).ready(function($) {

        var theme = Timeline.ClassicTheme.create();
        theme.autoWidth = true;
        //theme.event.tape.height = 20;
        
        var bandNames = #{bandNames_js.to_json};
        
        var bandInfos = [
            #{bandInfos_js.join(',')}
        ];
        for (var i = 1; i < bandInfos.length; i++)
          bandInfos[i].syncWith = 0;

        for (var i = 0; i < bandInfos.length; i++) {
            bandInfos[i].decorators = [
                new Timeline.SpanHighlightDecorator({
                    startDate:  #{Date.today.to_json},
                    endDate:    #{Date.tomorrow.to_json},
                    color:      "#FFC080",
                    opacity:    50,
                    startLabel: bandNames[i]
                })
            ];
        }

        Timeline.create(document.getElementById("my_timeline"), bandInfos);
      });
      HERECODE
    end
    
    r += content_tag :div, :id => "my_timeline", :style => "height: #{partition.values.sum * 40}px; border: 1px solid #aaa" do
      end
  end
  
end
