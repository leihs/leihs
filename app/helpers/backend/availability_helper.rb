module Backend::AvailabilityHelper

  def allocated_group(document_line)
    g = document_line.allocated_group
    content_tag :div do
      "#{_("Group")}: #{g}"
    end if g    
  end
  
  # TODO refactor to Date class
  # returns number of day from Unix epoch
  def date_to_i(date)
    date.to_time.to_i / 86400
  end
  
#  def groups_chart(model, inventory_pool)
#    
#    # TODO pass directly just (groups, changes) arguments ??
#    groups = inventory_pool.groups
#    changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool) # TODO filter out past changes ??
#    
#    values = []
#    x_ticks = []
#    group_totals = []
#
#    last = nil
#    changes.each do |c|
#      x_ticks << [date_to_i(c.date), c.date]
#      last = c.date
#    end
#    x_ticks << [date_to_i(last.tomorrow), last.tomorrow]
#    
#    r = javascript_include_tag "jquery/flot/jquery.flot.min.js", "jquery/flot/jquery.flot.stack.min.js"
#    r += content_tag :h4 do
#      _("General")
#    end
#    general_borrowable_size = changes.first.total_in_group(Group::GENERAL_GROUP_ID) # OPTIMIZE
#    r += content_tag :div, :id => "group_chart_general", :style => "height:#{(general_borrowable_size + 1) * 30}px;" do end
#
#      
#    groups.each do |group|
#      group_totals[group.id] = changes.first.total_in_group(group) # TODO .try
#      next unless group_totals[group.id] > 0
#
#      r += content_tag :h4 do
#        group
#      end
#      r += content_tag :div, :id => "group_chart_#{group.id}", :style => "height:#{(group_totals[group.id] + 1) * 30}px;" do end
#    end
#      
#    r += javascript_tag do
#        js = <<-HERECODE
#        
#          jQuery(document).ready(function($){
#              $.plot( $("#group_chart_general"),
#                      #{[{ :color => "#FF0000", :data => changes.map {|c| [date_to_i(c.date), c.out_quantity_in_group(Group::GENERAL_GROUP_ID)] }}].to_json},
#                      { series: {
#                            stack: true,
#                            lines: { lineWidth: 0,
#                                     fill: true,
#                                     steps: true }
#                        },
#                        xaxis: {
#                          min: #{date_to_i(changes.first.date)},
#                          max: #{date_to_i(changes.last.date.tomorrow)},
#                          ticks: #{x_ticks.to_json}
#                        },
#                        yaxis: {
#                          min: 0,
#                          max: #{general_borrowable_size+1},
#                          ticks: #{(1..general_borrowable_size).to_json}
#                        },
#                        grid: {
#                          backgroundColor: "#79b567"
#                        }
#                      });
#        HERECODE
#
#          groups.each do |group|
#            #next unless group_totals[group.id] > 0
#            data = changes.map {|c| [date_to_i(c.date), c.quantities.scoped_by_group_id(group).first.try(:out_quantity).to_i] }
#            data << [date_to_i(last.tomorrow), 0]
#
#            js += <<-HERECODE
#              $.plot( $("#group_chart_#{group.id}"),
#                      #{[{ :color => "#FF0000", :data => data }].to_json},
#                      { series: {
#                            stack: true,
#                            lines: { lineWidth: 0,
#                                     fill: true,
#                                     steps: true }
#                        },
#                        xaxis: {
#                          min: #{date_to_i(changes.first.date)},
#                          max: #{date_to_i(changes.last.date.tomorrow)},
#                          ticks: #{x_ticks.to_json}
#                        },
#                        yaxis: {
#                          min: 0,
#                          max: #{group_totals[group.id]+1},
#                          ticks: #{(1..group_totals[group.id]).to_json}
#                        },
#                        grid: {
#                          backgroundColor: "#79b567"
#                        }
#                      });
#            HERECODE
#          end
#
#        js += <<-HERECODE
#          });
#        HERECODE
#    end
#  end

  def availability_changes(changes)
    content_tag :table do
      changes.collect do |c|
        a = content_tag :tr do
          [_("Borrowable %s") % short_date(c.date),
           _("In Stock (%d)") % c.quantities.sum(:in_quantity),
           _("Not In Stock (%d)") % c.quantities.sum(:out_quantity),
           _("DocumentLines")].collect do |s|
            content_tag :th do
              s  
            end
          end.join
        end
        
        a += ([Group::GENERAL_GROUP_ID] + c.inventory_pool.groups).collect do |group|
          aq = c.quantities.scoped_by_group_id(group).first
          in_quantity = aq.try(:in_quantity).to_i
          out_quantity = aq.try(:out_quantity).to_i
          next if in_quantity.zero? and out_quantity.zero? 
          content_tag :tr do
            b = content_tag :td do
              "#{(group ? group : _("General"))}:"
            end
            b += [in_quantity, out_quantity].collect do |q|
              content_tag :td, :class => (q < 0 ? "valid_false" : nil) do
                q
              end
            end.join
            b += content_tag :td do
              content_tag :ol do
                aq.out_document_lines.collect do |odl|
                  content_tag :li do
                    dl = odl.document_line 
                    extra_info = dl.item.try(:inventory_code) || _("Quantity: %d") % dl.quantity
                    "#{dl.document.user} (#{extra_info}) => #{short_date(dl.end_date)}"
                  end
                end.join if aq.try(:out_document_lines)
              end
            end
          end
        end.join
      end.join
    end
  end
  
  def availability_periods_merged_groups(model, inventory_pool, user)
    start_date = Date.today
    end_date = Availability::ETERNITY
    groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
    changes = model.availability_changes.in(inventory_pool).between_from_most_recent_start_date(start_date, end_date).available_quantities_for_groups(groups)

    content_tag :table do
      a = content_tag :tr do
        [_("From date"),
         _("Available quantity")].collect do |s|
          content_tag :th do
            s  
          end
        end.join
      end
      
      a += changes.collect do |c|
        content_tag :tr do
          [short_date(c.date),
           c.available_quantity].collect do |s|
            content_tag :td do
              s  
            end
          end.join
        end
      end.join
    end
    
  end
  
end
