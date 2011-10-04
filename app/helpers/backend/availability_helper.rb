module Backend::AvailabilityHelper
# EVERYTHING AFTER HERE IS OLD STUFF
=begin
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

    capture_haml do
      haml_tag :table do
        haml_tag :tr do
          [_("From date"),
           _("Available quantity")].collect do |s|
            haml_tag :th do
              haml_concat s  
            end
          end
        end
        changes.collect do |c|
          haml_tag :tr do
            [short_date(c[0]),
             c[1]].collect do |s|
              haml_tag :td do
                haml_concat s  
              end
            end
          end
        end
      end
    end
  end
=end  
end
