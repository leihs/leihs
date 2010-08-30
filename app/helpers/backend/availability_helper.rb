module Backend::AvailabilityHelper
  
  # TODO refactor to Date class
  # returns number of day from Unix epoch
  def date_to_i(date)
    date.to_time.to_i / 86400
  end
  
  def groups_chart(model, inventory_pool)
    
    # TODO pass directly just (groups, changes) arguments ??
    groups = inventory_pool.groups
    changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool) # TODO filter out past changes ??
    changes << model.availability_changes.new_current_for_inventory_pool(inventory_pool) if changes.blank?
    
    values = []
    x_ticks = []
    group_totals = []

    last = nil
    changes.each do |c|
      x_ticks << [date_to_i(c.date), c.date]
      last = c.date
    end
    x_ticks << [date_to_i(last.tomorrow), last.tomorrow]
    
    r = javascript_include_tag "jquery/flot/jquery.flot.min.js", "jquery/flot/jquery.flot.stack.min.js"
      r += content_tag :h4 do
        _("General")
      end
    r += content_tag :div, :id => "group_chart_general", :style => "height:300px;" do end

      
    groups.each do |group|
      group_totals[group.id] = changes.first.total_in_group(group) # TODO .try
      #next unless group_totals[group.id] > 0

      r += content_tag :h4 do
        group
      end
      r += content_tag :div, :id => "group_chart_#{group.id}", :style => "height:#{(group_totals[group.id] + 1) * 30}px;" do end
      values << { :color => "#009900", :data => changes.map {|c| [date_to_i(c.date), c.available_quantities.available.scoped_by_group_id(group).first.try(:quantity).to_i] } }
      values << { :color => "#FF0000", :data => changes.map {|c| [date_to_i(c.date), c.available_quantities.borrowed.scoped_by_group_id(group).first.try(:quantity).to_i] } }
    end
    values << { :color => "#009900", :data => changes.map {|c| [date_to_i(c.date), c.general_borrowable_in_stock_size] } }
    values << { :color => "#FF0000", :data => changes.map {|c| [date_to_i(c.date), c.general_borrowable_not_in_stock_size] } }
      
    r += javascript_tag do
        js = <<-HERECODE
        
          jQuery(document).ready(function($){
              $.plot( $("#group_chart_general"),
                      #{values.to_json},
                      { series: {
                            stack: true,
                            /*
                            lines: { lineWidth: 1,
                                     fill: false,
                                     steps: true }
                            */
                            bars: { show: true,
                                    lineWidth: 0,
                                    barWidth: 1 }
                        },
                        xaxis: {
                          min: #{(Date.today.to_time.to_i - (86400 * 1)) / 86400},
                          max: #{(Date.today.to_time.to_i + (86400 * 10)) / 86400},
                          ticks: #{x_ticks.to_json}
                        },
                        yaxis: {
                          ticks: #{(0..inventory_pool.items.borrowable.scoped_by_model_id(model).count).to_json} // OPTIMIZE changes.first
                        }
                      });
        HERECODE

          groups.each do |group|
            #next unless group_totals[group.id] > 0
            data = changes.map {|c| [date_to_i(c.date), c.available_quantities.borrowed.scoped_by_group_id(group).first.try(:quantity).to_i] }
            data << [date_to_i(last.tomorrow), 0]

            js += <<-HERECODE
              $.plot( $("#group_chart_#{group.id}"),
                      #{[{ :color => "#FF0000", :data => data }].to_json},
                      { series: {
                            stack: true,
                            lines: { lineWidth: 1,
                                     fill: true,
                                     steps: true }
                        },
                        xaxis: {
                          min: #{(Date.today.to_time.to_i - (86400 * 1)) / 86400},
                          max: #{(Date.today.to_time.to_i + (86400 * 10)) / 86400},
                          ticks: #{x_ticks.to_json}
                        },
                        yaxis: {
                          min: 0,
                          max: #{group_totals[group.id]},
                          ticks: #{(1..group_totals[group.id]).to_json}
                        },
                        grid: {
                          backgroundColor: "#79b567"
                        }
                      });
            HERECODE
          end

        js += <<-HERECODE
          });
        HERECODE
    end
  end
  
end
