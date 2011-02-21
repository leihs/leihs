module Backend::AvailabilityHelper

  def allocated_group(document_line)
    g = document_line.allocated_group
    content_tag :div do
      "#{_("Group")}: #{g}"
    end if g    
  end

  # Display a table with the changes of availability of a model
  # along with information on who the customer is that borrowed
  # the item on that day 
  def availability_changes(availability)
    groups = [Group::GENERAL_GROUP_ID] + availability.inventory_pool.groups
    content_tag :table do
      availability.changes.collect do |c|
        a = content_tag :tr do
          [_("Borrowable %s") % short_date(c.date),
           _("In Stock (%d)") % c.quantities.collect(&:in_quantity).sum,
           _("Not In Stock (%d)") % c.quantities.collect(&:out_quantity).sum,
           _("DocumentLines")].collect do |s|
            content_tag :th do
              s  
            end
          end.join
        end
        
        a += groups.collect do |group|
          aq = c.quantities.detect {|q| q.group_id == group.try(:id) }
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
                aq.document_lines.collect do |dl|
                  content_tag :li do
                    extra_info = dl.item.try(:inventory_code) || _("Quantity: %d") % dl.quantity
                    link_to \
                      "#{dl.document.user} (#{extra_info}) => #{short_date(dl.end_date)}",
                      backend_inventory_pool_user_path(@current_inventory_pool, dl.document.user)
                  end
                end.join
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
