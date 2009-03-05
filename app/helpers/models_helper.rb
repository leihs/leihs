module ModelsHelper

  def javascript_include_flotr
    r = ""
#    r += javascript_include_tag :defaults

#    r += javascript_include_tag "flotr/lib/prototype-1.6.0.2.js"
#    r += javascript_include_tag "flotr/lib/excanvas.js" # IE
#    r += javascript_include_tag "flotr/lib/base64.js" # IE
#    r += javascript_include_tag "flotr/lib/canvas2image.js"
#    r += javascript_include_tag "flotr/lib/canvastext.js"

    r += javascript_include_tag "flotr/flotr.js"
    r
  end

  def canvas_for(obj)
    case obj.class.to_s
      when "Model"
        canvas_for_model(obj)
      when "Category"
        # TODO
     end
  end


  # Flotr Javascript Library required
  def canvas_for_model(model)
    config = {:canvas => {:width => 800, :height => 300},
              :line => {:height => 20},
              :range => {:start_days => -50, :end_days => 150},
              :title => {:xaxis => _('Time'), :x2axis => _('Available Quantity'), :yaxis => _('Items')}
              }
    items = @current_inventory_pool.items.by_model(model)
    canvas_height = (items.size * config[:line][:height])
    config[:canvas][:height] = canvas_height if canvas_height > config[:canvas][:height]
    config[:range][:start_sec] = config[:range][:start_days] * 86400
    config[:range][:end_sec] = config[:range][:end_days] * 86400

    today = Date.today
    x_ticks = [[today.to_time.to_i, '^']]
    x2_ticks = [[today.to_time.to_i, 'v']]
    y_ticks = []
    data = []
    first_date_in_chart = (today + config[:range][:start_days].days)
    
    dd = first_date_in_chart.at_beginning_of_month
    while dd.to_time.to_i < today.to_time.to_i + config[:range][:end_sec] do
      x_ticks << [dd.to_time.to_i, dd.strftime("%b")] if dd.to_time.to_i > today.to_time.to_i + config[:range][:start_sec] 
      dd = dd.next_month
    end
    
    items.each_with_index do |item, index|
      y = index + 1
      y_ticks << [y, item.inventory_code]
    end


    events = []
    html = ""
    
    lines = model.lines.select {|l| l.inventory_pool == @current_inventory_pool}
    lines_with_item = lines.select {|l| l.item }
    lines_without_item = lines - lines_with_item
    
    lines_with_item.each do |l|
      #debug# html += "<br>#{l.quantity}: #{l.start_date} - #{l.end_date} #{l.item.inventory_code}"
      start_date = l.start_date.to_time.to_i
      end_date = (l.returned_date ? l.returned_date.to_time.to_i : l.end_date.to_time.to_i) #old# l.end_date.tomorrow.to_time.to_i
      y = items.index(l.item) + 1
      events << {:start => start_date, :end => end_date, :y => y, :color => ((l.returned_date.nil? and l.end_date < today) ? 'red' : '#e3aa01')}
    end

    lines_without_item.each do |l|
      #debug# html += "<br>#{l.quantity}: #{l.start_date} - #{l.end_date}"
      start_date = l.start_date.to_time.to_i
      end_date = l.end_date.to_time.to_i #old# l.end_date.tomorrow.to_time.to_i
      l.quantity.times do
        y = nil
        (1..items.size).each do |k|
          unless events.any? {|e| e[:y] == k and e[:start] < end_date and e[:end] > start_date} #old# <= and >=
            y = k
            break
          end
        end
        events << {:start => start_date, :end => end_date, :y => y, :color => 'grey'} unless y.nil?
      end
    end

    events.each do |e|
      data << {:data => [[e[:start], e[:y]], [e[:end], e[:y]]], :color => e[:color]}
    end
    
    data << {:data => [[today.to_time.to_i, 0], [today.to_time.to_i, 0]], :xaxis => 2} # NOTE forcing to render x2axis # TODO 2502** keep from events?
    availability = model.available_periods_for_inventory_pool(@current_inventory_pool, current_user)
    availability.each do |a|
      #debug# html += "<br>#{a.start_date}: #{a.quantity}"
      dd = (a == availability.first ? first_date_in_chart + 1.day : a.start_date)
      x2_ticks << [dd.to_time.to_i, a.quantity.to_s] if dd.to_time.to_i > today.to_time.to_i + config[:range][:start_sec] and dd.to_time.to_i < today.to_time.to_i + config[:range][:end_sec]
    end

    html += javascript_include_flotr

    html += content_tag :div, :id => 'canvas_mouse_monitor', :style => "z-index: 9999; border: 1px solid black; position: fixed; left: 1020px;" do end

    html += content_tag :div, :id => 'canvas_container', :style => "width:#{config[:canvas][:width]}px;height:#{config[:canvas][:height]}px;" do end

    html += content_tag :div, :class => 'buttons' do
              r = ""
              r += content_tag :a, :id => 'canvas_prev' do _("Prev") end
              r += " "
              r += content_tag :a, :id => 'canvas_next' do _("Next") end
              r
            end
    
    html += <<-quoted_block
      <script type="text/javascript">
        
        var canvas_container = $('canvas_container');
        
        function draw_canvas(){
        
            var x_ticks = #{x_ticks.sort.to_json};
            var x2_ticks = #{x2_ticks.sort.to_json};
            var y_ticks = #{y_ticks.to_json};

            //old//x2_ticks.sort();

            var options = {
                    xaxis:{
                      title: '#{config[:title][:xaxis]}',
                      ticks: x_ticks,
                      min: #{today.to_time.to_i + config[:range][:start_sec]},
                      max: #{today.to_time.to_i + config[:range][:end_sec]}
                    },
                    x2axis:{
                      title: '#{config[:title][:x2axis]}',
                      ticks: x2_ticks,
                      min: #{today.to_time.to_i + config[:range][:start_sec]},
                      max: #{today.to_time.to_i + config[:range][:end_sec]}
                    },
                    yaxis:{
                      title: '#{config[:title][:yaxis]}',
                      ticks: y_ticks,
                      min: 0,
                      max: y_ticks.length + 1
                    },
                    grid:{
                      //verticalLines: false,
                      horizontalLines: false,
                      backgroundColor: '#ffffff'
                    },
                    lines: {
                      lineWidth: 5
                    },
                    selection: {
                      mode: 'x',     // => null, 'x', 'y' or 'xy'
                      color: '#B6D9FF',   // => color of the selection box
                      fps: 10     // => frames-per-second to draw the selection box.
                    },
                    mouse: {
                      track: true,    // => true to track mouse
                      position: 'ne',   // => position to show the track value box
                      relative: false,
                      trackFormatter: function(obj){ return y_ticks[obj.y][1] + '<br/>' + show_date(new Date(obj.x * 1000)); },
                      margin: 5,    // => margin for the track value box
                      color: '#ff3f19', // => color for the tracking points, null to hide points
                      trackDecimals: 0, // => number of decimals for track values
                      radius: 3,    // => radius of the tracking points
                      sensibility: 2    // => the smaller this value, the more precise you've to point with the mouse
                    }
                  };

            function drawGraph(opts){
              var o = Object.extend(Object.clone(options), opts || {});
              return Flotr.draw(canvas_container,
                                #{data.to_json},
                                o);
            } 
            
            var f = drawGraph();

            canvas_container.observe('flotr:select', function(evt){
              var area = evt.memo[0];
              
              f = drawGraph({
                xaxis:{
                  title: f.axes.x.options.title, // forwarding value
                  ticks: f.axes.x.options.ticks, // forwarding value
                  min:area.x1,
                  max:area.x2
                },
                x2axis:{
                  title: f.axes.x2.options.title, // forwarding value
                  ticks: f.axes.x2.options.ticks, // forwarding value
                  min:area.x1,
                  max:area.x2
                }
              });
            });


            function canvas_navigate(delta_days){
              delta_days = delta_days * 86400;

              f = drawGraph({
                xaxis:{
                  title: f.axes.x.options.title, // forwarding value
                  ticks: f.axes.x.options.ticks, // forwarding value
                  min: f.axes.x.min + delta_days,
                  max: f.axes.x.max + delta_days
                },
                x2axis:{
                  title: f.axes.x2.options.title, // forwarding value
                  ticks: f.axes.x2.options.ticks, // forwarding value
                  min: f.axes.x2.min + delta_days,
                  max: f.axes.x2.max + delta_days
                }
              });
            }

            $('canvas_prev').observe('click', function(evt){ canvas_navigate(-30) });
            $('canvas_next').observe('click', function(evt){ canvas_navigate(30) });

            canvas_container.observe('flotr:mousemove', function(evt){
              var x = evt.memo[1].x2;
              var d = new Date(x * 1000);
              var canvas_mouse_monitor = $('canvas_mouse_monitor');
              for(var i = x2_ticks.length - 1; i > 0 && x2_ticks[i][0] > evt.memo[1].x2; i--);
              canvas_mouse_monitor.innerHTML = '<h4>' + show_date(d) + '<br/>availables: ' + x2_ticks[i][1] + '</h4>';
              canvas_mouse_monitor.style.top = (evt.memo[0].clientY + 10) + 'px';
              //canvas_mouse_monitor.style.left = (evt.memo[0].clientX + 10) + 'px';
            });

        }

       document.observe('dom:loaded', draw_canvas()); 

      </script>    
    quoted_block
    
    html
  end


  # Flotr Javascript Library required
  def pie_for_model(model)
    config = {:canvas => {:width => 800, :height => 300}}

    data = []
    model.inventory_pools.each do |ip|
      n = ip.items.by_model(model).count
      data << {:data => [[0, n]], :label => ip.name}
    end
    
    html = ""
    html += javascript_include_flotr
  
    html += content_tag :div, :id => 'canvas_container', :style => "width:#{config[:canvas][:width]}px;height:#{config[:canvas][:height]}px;" do
            end

    html += <<-quoted_block
      <script type="text/javascript">
      
        var canvas_container = $('canvas_container');
      
        function draw_canvas(){
            var f = Flotr.draw(canvas_container,
                               #{data.to_json},
                               {
                                  grid: {
                                    verticalLines: false, 
                                    horizontalLines: false
                                  },
                                  xaxis: {showLabels: false},
                                  yaxis: {showLabels: false},
                                  legend:{show: false},
                                  pie: {
                                    show: true,           // => setting to true will show bars, false will hide
                                    //lineWidth: 1,          // => in pixels
                                    //fill: true,            // => true to fill the area from the line to the x axis, false for (transparent) no fill
                                    //fillColor: null,       // => fill color
                                    //fillOpacity: 0.6,      // => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
                                    //explode: 6,
                                    //sizeRatio: 0.6,
                                    //startAngle: Math.PI/4,
                                    labelFormatter: function(slice) { return slice.name + ' (' + slice.y + ')'; },
                                    //pie3D: false,
                                    //pie3DviewAngle: (Math.PI/2 * 0.8),
                                    //pie3DspliceThickness: 20
                                  }
                                });
        }
        
        document.observe('dom:loaded', draw_canvas()); 
             
      </script>    
    quoted_block
    
    html
  end

end
