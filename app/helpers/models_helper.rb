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

  def canvas_for(obj, inventory_pool, params = {})
    case obj.class.to_s
      when "Model"
        canvas_for_model(obj, inventory_pool, params)
      when "Category"
        # TODO
     end
  end


  # Flotr Javascript Library required
  def canvas_for_model(model, inventory_pool, params = {})
    
    #return if items.empty?
    
    config = {:canvas => {:width => 800, :height => 300},
              :line => {:height => 20},
              :range => {:start_days => -50, :end_days => 150},
              :title => {:xaxis => _('Time'), :x2axis => _('Available Quantity'), :yaxis => _('Items')}
              }
    items = case params[:filter]
              when "own"
                inventory_pool.own_items.by_model(model).all(:order => "is_borrowable DESC, inventory_code DESC")
              else
                inventory_pool.items.by_model(model).all(:order => "is_borrowable DESC, inventory_code DESC")
            end
    canvas_height = (items.size * config[:line][:height])
    config[:canvas][:height] = canvas_height if canvas_height > config[:canvas][:height]
    config[:range][:start_sec] = config[:range][:start_days] * 86400
    config[:range][:end_sec] = config[:range][:end_days] * 86400

    today = Date.today
    x_ticks = [[today.to_time.to_i, '^']]
    x2_ticks = []
    y_ticks = []
    data = []
    events = []
    items_users = {}
    html = ""
    first_date_in_chart = (today + config[:range][:start_days].days)
    
    dd = first_date_in_chart.at_beginning_of_month
    while dd.to_time.to_i < today.to_time.to_i + config[:range][:end_sec] do
      x_ticks << [dd.to_time.to_i, dd.strftime("%b")] if dd.to_time.to_i > today.to_time.to_i + config[:range][:start_sec] 
      dd = dd.next_month
    end
    
 
    items.each_with_index do |item, index|
      y = index + 1
      styled_inventory_code = (item.is_borrowable? ? item.inventory_code : "<span style='color:red;'>#{item.inventory_code}</span>") 
      y_ticks << [y, styled_inventory_code]
    end

    lines = model.lines.select {|l| l.inventory_pool == inventory_pool}
    lines_with_item = lines.select {|l| l.item }
    lines_without_item = lines - lines_with_item

    lines_with_item.each do |l|
      next if l.item.retired?
      y = items.index(l.item)
      next if y.nil?
      y += 1
      #debug# html += "<br>#{l.quantity}: #{l.start_date} - #{l.end_date} #{l.item.inventory_code}"
      start_date = l.start_date.to_time.to_i
      end_date = (l.returned_date ? (l.returned_date + 12.hours).to_time.to_i : (l.end_date + 12.hours).to_time.to_i)

      color = if l.returned_date
                '#e1e157'
              elsif l.end_date < today
                'red'
              else
                '#e3aa01'
              end
      events << {:start => start_date, :end => end_date, :y => y, :color => color}
      #TODO optimize the following horrible data-structure out and just use the Jquery oriented Flot library, which offers more flexibility in graph handling.
      if items_users[l.item.inventory_code].nil?
        items_users[l.item.inventory_code] = {start_date =>[ l.document.user.name.to_s, l.document.user.phone.to_s, end_date ], end_date => [start_date]}
      else
        items_users[l.item.inventory_code].merge!(start_date => [l.document.user.name.to_s, l.document.user.phone.to_s, end_date], end_date => [start_date])
      end
    end
    lines_without_item.each do |l|
      #debug# html += "<br>#{l.quantity}: #{l.start_date} - #{l.end_date}"
      start_date = l.start_date.to_time.to_i
      end_date = (l.end_date + 12.hours).to_time.to_i
      l.quantity.times do
        y = nil
        (1..items.size).each do |k|
          unless events.any? {|e| e[:y] == k and e[:start] < end_date and e[:end] > start_date} #old# <= and >=
            y = k
            break
          end
        end

        unless y.nil?
          events << {:start => start_date, :end => end_date, :y => y, :color => 'grey'} 

          #TODO make less clunky
          inventory_code = y_ticks[y-1][1]
          if l.instance_of? OrderLine
            #TODO further horrible data-structure, pending Flot implementation.
            if items_users[inventory_code].nil?
               items_users[inventory_code] = {start_date => [l.order.user.name.to_s, l.document.user.phone.to_s, end_date], end_date => [start_date]}
             else
               items_users[inventory_code].merge!(start_date => [l.order.user.name.to_s, l.document.user.phone.to_s, end_date], end_date => [start_date])
             end
          else
            if items_users[inventory_code].nil?
               items_users[inventory_code] = {start_date => [l.document.user.name.to_s, l.document.user.phone.to_s, end_date], end_date => [start_date]}
            else
               items_users[inventory_code].merge!(start_date => [l.document.user.name.to_s, l.document.user.phone.to_s, end_date], end_date => [start_date])
            end
          end
        end
      end
    end

    events.each do |e|
      data << {:data => [[e[:start], e[:y]], [e[:end], e[:y]]], :color => e[:color]}
    end
    
    data << {:data => [[today.to_time.to_i, 0], [today.to_time.to_i, 0]], :xaxis => 2} # NOTE forcing to render x2axis # TODO 2502** keep from events?
    availability = model.available_periods_for_inventory_pool(inventory_pool, current_user)
    availability.each do |a|
      #debug# html += "<br>#{a.start_date}: #{a.quantity}"
      dd = (a == availability.first ? first_date_in_chart + 1.day : a.start_date)
      x2_ticks << [dd.to_time.to_i, a.quantity.to_s, ] if dd.to_time.to_i > today.to_time.to_i + config[:range][:start_sec] and dd.to_time.to_i < today.to_time.to_i + config[:range][:end_sec]
    end

    html += javascript_include_flotr

    html += content_tag :div, :id => 'canvas_mouse_monitor', :style => "position: absolute; z-index: 9999; border: 1px solid black; width: 200px;" do end

    html += content_tag :div, :id => 'canvas_container', :style => "width:#{config[:canvas][:width]}px;height:#{config[:canvas][:height]}px;" do end

    html += content_tag :div, :class => 'buttons', :style => "text-align: center;" do
              r = ""
              r += content_tag :a, :id => 'canvas_prev' do "< #{_("Prev")}" end
              r += " "
              r += content_tag :a, :id => 'canvas_next' do "#{_("Next")} >" end
              r += " "
              r += content_tag :a, :id => 'canvas_zoom_reset' do "#{_("Reset Zoom")}" end
            end
    
    html += <<-HERECODE
      <script type="text/javascript">
        
        var canvas_container = $('canvas_container');
        
        function draw_canvas(){
        
            var x_ticks = #{x_ticks.sort.to_json};
            var x2_ticks = #{x2_ticks.sort.to_json};
            var y_ticks = #{y_ticks.to_json};
            var items_users = #{items_users.to_json};

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
                      title: '', //'#{config[:title][:yaxis]}',
                      ticks: y_ticks,
                      min: 0,
                      max: y_ticks.length + 1
                    },
                    grid:{
                      //verticalLines: false,
                      horizontalLines: false,
                      backgroundColor: '#ffffff',
                    	tickColor: '#dddddd'
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
                      trackFormatter: function(obj){ 
                        if (items_users[y_ticks[(obj.y)-1][1]][obj.x].length > 1)
                          {
                            var username = items_users[y_ticks[(obj.y)-1][1]][obj.x][0];
                            var userphone = items_users[y_ticks[(obj.y)-1][1]][obj.x][1];
                            var other_val = items_users[y_ticks[(obj.y)-1][1]][obj.x][2];
                          }
                        else
                          {
                            var other_val = items_users[y_ticks[(obj.y)-1][1]][obj.x][0]
                            var username = items_users[y_ticks[(obj.y)-1][1]][other_val][0];
                            var userphone = items_users[y_ticks[(obj.y)-1][1]][other_val][1];
                          }
                        if (obj.x < other_val)
                          { var from_date = obj.x;
                            var to_date = other_val; }
                        else
                          { var from_date = other_val;
                            var to_date = obj.x; }
                        return y_ticks[(obj.y)-1][1] + '<br/>' + show_date(new Date(from_date * 1000),false) + ' - ' + show_date(new Date(to_date * 1000),false) + '<br/>Client: ' + username + '<br/>Phone: ' + userphone;
                       },
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

            $('canvas_prev').observe('click', function(evt){ canvas_navigate(-30); });
            $('canvas_next').observe('click', function(evt){ canvas_navigate(30); });
            $('canvas_zoom_reset').observe('click', function(){drawGraph()});
            
            canvas_container.observe('flotr:mousemove', function(evt){
              var x_timestamp = evt.memo[1].x2;
              var mouse_monitor_x = evt.memo[1].absX + 15;
              var mouse_monitor_y = evt.memo[1].absY + 15;
              var canvas_mouse_monitor = $('canvas_mouse_monitor');
              for(var i = x2_ticks.length - 1; i > 0 && x2_ticks[i][0] > evt.memo[1].x2; i--);
              canvas_mouse_monitor.innerHTML = '<h4>' + show_date(new Date(x_timestamp * 1000),true) + '<br/>available: ' + x2_ticks[i][1] + '</h4>';
              canvas_mouse_monitor.style.left = mouse_monitor_x + 'px';
              canvas_mouse_monitor.style.top = mouse_monitor_y + 'px';
            });

        }

       document.observe('dom:loaded', function(evt){ draw_canvas(); }); 

      </script>    
    HERECODE
    
    content_tag :div, :id => 'flotr_container' do
      html
    end
  end

  # Flotr Javascript Library required
  def canvas_for_model_in_inventory_pools(model, inventory_pools = [])
    config = {:canvas => {:width => 800, :height => 160},
              :line => {:height => 20},
              :range => {:start_days => 0, :end_days => 200},
              :title => {:xaxis => _('Time'), :x2axis => _('Available Quantity'), :yaxis => _('Inventory Pools')}
              }
    inventory_pools &= model.inventory_pools
    canvas_height = (inventory_pools.size * config[:line][:height])
    config[:canvas][:height] = canvas_height if canvas_height > config[:canvas][:height]
    config[:range][:start_sec] = config[:range][:start_days] * 86400
    config[:range][:end_sec] = config[:range][:end_days] * 86400

    today = Date.today
    x_ticks = [[today.to_time.to_i, '^']]
    x2_ticks = [[today.to_time.to_i, '.']] # TODO compute total availables
    y_ticks = []
    data = []
    data << {:data => [[today.to_time.to_i, 0], [today.to_time.to_i, 0]], :xaxis => 2} # NOTE forcing to render x2axis
    html = ""
    all_availabilities = []
    first_date_in_chart = (today + config[:range][:start_days].days)
    
    dd = first_date_in_chart.at_beginning_of_month
    while dd.to_time.to_i < today.to_time.to_i + config[:range][:end_sec] do
      x_ticks << [dd.to_time.to_i, dd.strftime("%b")] if dd.to_time.to_i > today.to_time.to_i + config[:range][:start_sec] 
      dd = dd.next_month
    end
    
    
    inventory_pools.each_with_index do |inventory_pool, index|
      y = index + 1
      y_ticks << [y, inventory_pool.name]

      availability = model.available_periods_for_inventory_pool(inventory_pool, current_user)
      availability.each do |a|
        next if a.quantity < 1
# TODO ????       next a.end_date < a.start_date if a.end_date
        all_availabilities << a
        data << { :data => [[a.start_date.to_time.to_i, y], [(a.end_date || a.start_date + 1.year).tomorrow.to_time.to_i, y]],
                  :color => '#e3aa01',
                  :lines => {:lineWidth => [a.quantity, config[:line][:height]].min} }
      end
    end

    availability = Availability.new(0)
    availability.model = model
    availability.reservations(all_availabilities)
    quantity_periods = availability.periods
    quantity_periods.each do |a|
      dd = (a == quantity_periods.first ? first_date_in_chart + 1.day : a.start_date)
      x2_ticks << [dd.to_time.to_i, a.quantity.abs.to_s] if dd.to_time.to_i > today.to_time.to_i + config[:range][:start_sec] and dd.to_time.to_i < today.to_time.to_i + config[:range][:end_sec]
    end


    html += javascript_include_flotr

    html += content_tag :div, :id => 'canvas_mouse_monitor', :style => "position: absolute; z-index: 9999; border: 1px solid black; width: 200px;" do end

    html += content_tag :div, :id => 'canvas_container', :style => "width:#{config[:canvas][:width]}px;height:#{config[:canvas][:height]}px;" do end

    html += content_tag :div, :class => 'buttons', :style => "text-align: center;" do
              r = ""
              r += content_tag :a, :id => 'canvas_prev' do "< #{_("Prev")}" end
              r += " "
              r += content_tag :a, :id => 'canvas_next' do "#{_("Next")} >" end
              r
            end
    
    html += <<-HERECODE
      <script type="text/javascript">
        
        var canvas_container = $('canvas_container');
        
        function draw_canvas(){
        
            var x_ticks = #{x_ticks.sort.to_json};
            var x2_ticks = #{x2_ticks.sort.to_json};
            var y_ticks = #{y_ticks.to_json};

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
                      horizontalLines: false,
                      backgroundColor: '#ffffff'
                    },
                    selection: {
                      mode: 'x',     // => null, 'x', 'y' or 'xy'
                      color: '#B6D9FF',   // => color of the selection box
                      fps: 10     // => frames-per-second to draw the selection box.
                    },
                    mouse: {
                      track: false,    // => true to track mouse
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

            $('canvas_prev').observe('click', function(evt){ canvas_navigate(-30); });
            $('canvas_next').observe('click', function(evt){ canvas_navigate(30); });

            canvas_container.observe('flotr:mousemove', function(evt){
              var x_timestamp = evt.memo[1].x2;
              var mouse_monitor_x = evt.memo[1].absX + 15;
              var mouse_monitor_y = evt.memo[1].absY + 15;
              var canvas_mouse_monitor = $('canvas_mouse_monitor');
              for(var i = x2_ticks.length - 1; i > 0 && x2_ticks[i][0] > evt.memo[1].x2; i--);
              canvas_mouse_monitor.innerHTML = '<h4>' + show_date(new Date(x_timestamp * 1000)) + '<br/>available: ' + x2_ticks[i][1] + '</h4>';
              canvas_mouse_monitor.style.left = mouse_monitor_x + 'px';
              canvas_mouse_monitor.style.top = mouse_monitor_y + 'px';
            });

        }

       document.observe('dom:loaded', function(evt){ draw_canvas(); }); 

      </script>    
    HERECODE
    
    content_tag :div, :id => 'flotr_container', :style => "width:#{config[:canvas][:width]}px;" do
      html
    end
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

    html += javascript_tag do
      <<-HERECODE
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
             
      HERECODE
    end
    
    html
  end


end
