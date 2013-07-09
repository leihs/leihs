class Borrow::OrdersController < Borrow::ApplicationController

  def index
  end

######################################################################

  def unsubmitted_order
    @grouped_lines = @order.lines.group_by{|l| [l.start_date, l.inventory_pool] }
  end

  def submit
    @order.created_at = DateTime.now
    unless @order.submit(params[:purpose])
      flash[:error] = @order.errors.full_messages.uniq.join("\n")
      redirect_to borrow_unsubmitted_order_path
    else
      flash[:notice] = _("The order has been successfully submitted, but is NOT YET CONFIRMED.")
      redirect_to borrow_start_path
    end
  end

  def remove
    @order.destroy
    redirect_to borrow_start_path
  end

######################################################################

  # FIXME refactor this method according to the new borrow section and adapt tests! (features/availability_inventory_pool_story.feature)
  def add_line(model_id = params[:model_id],
      model_group_id = params[:model_group_id],
      user_id = params[:user_id] || current_user.id, # OPTIMIZE
      quantity = params[:quantity] || 1,
      start_date = params[:start_date] || Date.today,
      end_date = params[:end_date] || Date.tomorrow,
      inventory_pool_id = params[:inventory_pool_id] || nil)
    if model_group_id
      model = Template.find(model_group_id)
      inventory_pool_id ||= model.inventory_pools.first.id
    else
      model = current_user.models.find(model_id)
    end

    if start_date.is_a? String
      sd = start_date.split('.').map{|x| x.to_i}
      start_date = Date.new(sd[2],sd[1],sd[0])
    end
    if end_date.is_a? String
      ed = end_date.split('.').map{|x| x.to_i}
      end_date = Date.new(ed[2],ed[1],ed[0])
    end

    inventory_pool = (inventory_pool_id ? current_user.inventory_pools.find(inventory_pool_id) : nil)

    model.add_to_document(@order, user_id, quantity, start_date, end_date, inventory_pool)

    flash[:notice] = @order.errors.full_messages.uniq unless @order.save
    redirect_to backend_inventory_pool_model_path inventory_pool_id, model
  end

  def remove_lines(line_ids = params[:line_ids])
    lines = @order.lines.find(line_ids)
    lines.each {|l| @order.remove_line(l, current_user.id) }
    redirect_to borrow_unsubmitted_order_path
  end

  def timed_out
  end

end
