module ModelsHelper

  def canvas_for(obj)
    case obj.class.to_s
      when "Model"
        #canvas_for_model(obj)
        canvas_for_model_with_flotr(obj)
      when "Category"
        # TODO
     end
  end


#  def canvas_for_model(model)
#    config = {:canvas => {:width => 800, :height => 300},
#              :line => {:height => 20},
#              :frame => {:width => 2, :height => 10},
#              :margin => {:top => 50, :right => 80, :bottom => 50, :left => 80 } }
#    items = @current_inventory_pool.items.by_model(model)
#    config[:canvas][:height] = items.size * config[:line][:height]
#    
#    html = content_tag :div, :id => 'canvas_container', :style => "position: relative; cursor: default; overflow: auto; margin: 10px; border: 1px solid black;" do
#        r = "<canvas id='canvas' width='#{config[:canvas][:width]}' height='#{config[:canvas][:height]}' style='margin: #{config[:margin][:top]}px #{config[:margin][:right]}px #{config[:margin][:bottom]}px #{config[:margin][:left]}px; border: 1px solid red;'></canvas>"
#        r += content_tag :div, :style => "font-size: smaller; color: rgb(84, 84, 84);" do
#          s = ""
#          items.each_with_index do |item, index|
#            s += "<span style='border: 1px solid black; position: absolute; top: #{index * config[:line][:height] + config[:margin][:top]}px; left: 1px; width: 75px; text-align: right;'>#{item.inventory_code}</span>"
#          end
#          s
#        end
#        r
#    end
#    
#
#     html += javascript_tag do
#        j = "
#          // TODO pass ruby vars to js
#          var frame_width = #{config[:frame][:width]};
#          var color_line = 200;
#          
#          function draw_grid(ctx){
#              ctx.fillStyle = 'rgba(0, 200, 200, 0.5)';
#              ctx.fillRect (#{config[:canvas][:width] / 2}, 0, frame_width, #{config[:canvas][:height]});
#          
#          }
#          
#          function draw() {
#            var canvas = $('canvas');
#            if (canvas.getContext) {
#              var ctx = canvas.getContext('2d');
#              ctx.clearRect(0,0,#{config[:canvas][:width]},#{config[:canvas][:height]}); // clear canvas
#      
#            // fillText requires Gecko 1.9.1 (Firefox 3.1)
#            // ctx.fillText('Sample String', 120, 10);
#            
#              draw_grid(ctx);
#            
#              ctx.fillStyle = 'rgb('+color_line+',0,0)';
#         "
#  
#         items.each_with_index do |item, index|
#           item.contract_lines.each do |cl|
#             interval = (cl.end_date - cl.start_date).abs + 1
#             j += "ctx.fillRect (#{(config[:canvas][:width] / 2) + (cl.start_date - Date.today) * config[:frame][:width]}, #{index * config[:line][:height]}, #{interval * config[:frame][:width]}, #{config[:frame][:height]});"
#           end
#         end
#         
#         j += "
#            }
#          }
#      
#        draw();
#        
#        function doKeyDown(evt){
#          //alert(evt.keyCode);
#          if(evt.keyCode == 38) {
#            frame_width = frame_width * 2;
#          }
#          if(evt.keyCode == 40) {
#            frame_width = frame_width / 2;
#          }
#          draw();
#        }
#        
#        window.addEventListener('keydown',doKeyDown,true);
#        "
#        j
#      end
#
#    html
#  end


  def canvas_for_model_with_flotr(model)
    config = {:canvas => {:width => 800, :height => 300},
              :line => {:height => 20},
              :range => {:start => -50, :end => 150}}
    items = @current_inventory_pool.items.by_model(model)
    canvas_height = (items.size * config[:line][:height])
    config[:canvas][:height] = canvas_height if canvas_height > config[:canvas][:height]

    today = Date.today
    x_ticks = [[today.jd, _("Today")]]
    
    dd = (today + config[:range][:start].days).at_beginning_of_month
    while dd.jd < today.jd + config[:range][:end] do
      x_ticks << [dd.jd, dd.strftime("%b")] if dd.jd > today.jd + config[:range][:start]
      dd = dd.next_month
    end
    
    y_ticks = []
    data = []
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

    model.contract_lines.each do |cl|
      s = cl.start_date.jd
      e = cl.end_date.tomorrow.jd
      j = if cl.item
        items.index(cl.item) + 1
      else
        rand items.size + 1
      end
      data << [[s, j], [e, j]]
    end

    html = ""
#      html += javascript_include_tag "flotr/lib/prototype-1.6.0.2.js"
#      html += javascript_include_tag "flotr/lib/excanvas.js" # IE
#      html += javascript_include_tag "flotr/lib/base64.js" # IE
#      html += javascript_include_tag "flotr/lib/canvas2image.js"
#      html += javascript_include_tag "flotr/lib/canvastext.js"
    html += javascript_include_tag "flotr/flotr-0.2.0-alpha.js"
  
    html += content_tag :div, :id => 'canvas_container', :style => "width:#{config[:canvas][:width]}px;height:#{config[:canvas][:height]}px;" do
            end

    html += <<-quoted_block
      <script type="text/javascript">
        document.observe('dom:loaded', function(){
        
            var f = Flotr.draw($('canvas_container'),
                               #{data.to_json},
                               {
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
                                    position: 'se',   // => position to show the track value box
                                    trackFormatter: function(obj){ return 'x = ' + obj.x +', y = ' + obj.y; },
                                    margin: 3,    // => margin for the track value box
                                    color: '#ff3f19', // => color for the tracking points, null to hide points
                                    trackDecimals: 0, // => number of decimals for track values
                                    radius: 3,    // => radius of the tracking points
                                    sensibility: 2    // => the smaller this value, the more precise you've to point with the mouse
                                  }
                                });
        });     
      </script>    
    quoted_block
    
    html
  end
end
