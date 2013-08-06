class Backend::OrdersController < Backend::BackendController
  
  before_filter do
    params[:order_id] ||= params[:id] if params[:id]
    @order = current_inventory_pool.orders.find(params[:order_id]) if params[:order_id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end

######################################################################

  def index(filter = params[:filter],
            query = params[:query],
            year = params[:year].to_i,
            month = params[:month].to_i,
            paginate = params[:paginate].try{|x| x == "false" ? false : true},
            page = params[:page])

    conditions = { :inventory_pool_id => current_inventory_pool.id }
    conditions[:user_id] = @user.id if @user
        
    scope = case filter
              when "approved"
                :approved
              when "rejected"
                :rejected
              when "pending"
                :submitted
              else
                :scoped
            end
    
    # unscoped is for skip de default_scope
    sql = Order.unscoped.send(scope).where(conditions)
    search_sql = sql.search(query)

    time_range = if not year.zero? and month.zero?
      "YEAR(orders.created_at) = %d" % year
    elsif not year.zero?
      "YEAR(orders.created_at) = %d AND MONTH(orders.created_at) = %d" % [year, month]
    else
      {}
    end
        
    @orders = search_sql.where(time_range).order("orders.created_at DESC")
    @orders = @orders.paginate(:page => page, :per_page => Setting::PER_PAGE) if paginate != false
    
    respond_to do |format|
      format.html { 
        @total_entries = sql.where(time_range).count 
        @available_months = unless year.zero?
          []
        else
          # OPTIMIZE: DISTINCT instead of .uniq 
          search_sql.select("MONTH(orders.created_at) AS month").where("YEAR(orders.created_at) = ?", year).map(&:month).uniq.sort
        end

        # OPTIMIZE: DISTINCT instead of .uniq 
        @available_years = search_sql.select("YEAR(orders.created_at) AS year").map(&:year).uniq.sort
      }
      format.json { render :json => view_context.json_for(@orders, {:preset => :order_minimal}) }
    end
  end

  def show(with = params[:with])
    respond_to do |format|
      format.html
      format.json {
        render :json => view_context.json_for(@order, with)
      }
    end
  
  end
    
end
