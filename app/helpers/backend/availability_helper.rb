module Backend::AvailabilityHelper

  def allocated_group(document_line)
    g = document_line.allocated_group
    content_tag :div do
      "#{_("Group")}: #{g}"
    end if g    
  end

  def availability_periods_merged_groups(model, inventory_pool, user)
    start_date = Date.today
    end_date = Availability::ETERNITY
    groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
    changes = model.availability_changes_in(inventory_pool).changes.between(start_date, end_date).available_quantities_for_groups(groups)

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
          [short_date(c[0]),
           c[1]].collect do |s|
            content_tag :td do
              s  
            end
          end.join
        end
      end.join
    end
    
  end
  
end
