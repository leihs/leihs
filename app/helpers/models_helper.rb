module ModelsHelper

  def javascript_include_flotr
    r = ""
#    r += javascript_include_tag "flotr/lib/prototype-1.6.0.2.js"
#    r += javascript_include_tag "flotr/lib/excanvas.js" # IE
#    r += javascript_include_tag "flotr/lib/base64.js" # IE
#    r += javascript_include_tag "flotr/lib/canvas2image.js"
#    r += javascript_include_tag "flotr/lib/canvastext.js"
    r += javascript_include_tag "flotr/flotr-0.2.0-alpha.js"
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
              :range => {:start => -50, :end => 150}}
    items = @current_inventory_pool.items.by_model(model)
    canvas_height = (items.size * config[:line][:height])
    config[:canvas][:height] = canvas_height if canvas_height > config[:canvas][:height]

    today = Date.today
    x_ticks = [[today.jd, _("Today")]]
    y_ticks = []
    data = []
    
    dd = (today + config[:range][:start].days).at_beginning_of_month
    while dd.jd < today.jd + config[:range][:end] do
      x_ticks << [dd.jd, dd.strftime("%b")] if dd.jd > today.jd + config[:range][:start]
      dd = dd.next_month
    end
    
    items.each_with_index do |item, index|
      j = index + 1
      y_ticks << [j, item.inventory_code]
#old#
#      item.contract_lines.each do |cl|
#        s = cl.start_date.jd
#        e = cl.end_date.tomorrow.jd
#        data << [[s, j], [e, j]]
#      end
    end

#old#
#    model.lines.each do |l|
#      s = l.start_date.jd
#      e = l.end_date.tomorrow.jd
#      if l.item
#        j = items.index(l.item) + 1
#        #old# data << [[s, j], [e, j]]
#        data << {:data => [[s, j], [e, j]], :color => '#e3aa01'}
#      else
#        l.quantity.times do
#          j = rand items.size + 1 # TODO
#          data << {:data => [[s, j], [e, j]], :color => 'grey'}
#        end
#      end
#    end


    events = []
    
    lines = model.lines.select {|l| l.inventory_pool == @current_inventory_pool}
    lines_with_item = lines.select {|l| l.item }
    lines_without_item = lines - lines_with_item
    
    lines_with_item.each do |l|
      start_date = l.start_date.jd
      end_date = l.end_date.tomorrow.jd
      j = items.index(l.item) + 1
      events << {:start => start_date, :end => end_date, :y => j, :assigned => true}
    end

    lines_without_item.each do |l|
      start_date = l.start_date.jd
      end_date = l.end_date.tomorrow.jd
      l.quantity.times do
        j = nil
        (1..items.size).each do |k|
          unless events.any? {|e| e[:y] == k and e[:start] <= end_date and e[:end] >= start_date}
            j = k
            break
          end
        end
        events << {:start => start_date, :end => end_date, :y => j, :assigned => false} unless j.nil?
      end
    end

    events.each do |e|
      data << {:data => [[e[:start], e[:y]], [e[:end], e[:y]]], :color => (e[:assigned] ? '#e3aa01' : 'grey')}
    end

    html = ""
    html += javascript_include_flotr
  
    html += content_tag :div, :id => 'canvas_container', :style => "width:#{config[:canvas][:width]}px;height:#{config[:canvas][:height]}px;" do
            end

    html += <<-quoted_block
      <script type="text/javascript">
        document.observe('dom:loaded', function(){

            var options = {
                    xaxis:{
                      //noTicks: 7,
                      //tickFormatter: function(n){ return '('+n+')'; }, // => displays tick values between brackets.
                      //labelsAngle: 45,
                      ticks: #{x_ticks.to_json},
                      min: #{today.jd + config[:range][:start]},
                      max: #{today.jd + config[:range][:end]}
                    },
                    yaxis:{
                      ticks: #{y_ticks.to_json},
                      min: 0,
                      max: #{y_ticks.size + 1}
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
                      trackFormatter: function(obj){ return 'x = ' + obj.x +', y = ' + obj.y; },
                      margin: 5,    // => margin for the track value box
                      color: '#ff3f19', // => color for the tracking points, null to hide points
                      trackDecimals: 0, // => number of decimals for track values
                      radius: 3,    // => radius of the tracking points
                      sensibility: 2    // => the smaller this value, the more precise you've to point with the mouse
                    }
                  };

            function drawGraph(opts){
              var o = Object.extend(Object.clone(options), opts || {});
              return Flotr.draw($('canvas_container'),
                                #{data.to_json},
                                o);
            } 
            
            var f = drawGraph();

            $('canvas_container').observe('flotr:select', function(evt){
              var area = evt.memo[0];
              
              f = drawGraph({
                xaxis:{
                  ticks: #{x_ticks.to_json},
                  min:area.x1,
                  max:area.x2
                },
                yaxis:{
                  ticks: #{y_ticks.to_json},
                  min:area.y1,
                  max:area.y2
                }
              });
            });

        });     
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
        document.observe('dom:loaded', function(){
        
            var f = Flotr.draw($('canvas_container'),
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
            //console.log(f);
        });     
      </script>    
    quoted_block
    
    html
  end

end
