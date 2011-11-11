class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    with = { :inventory_pool_id => current_inventory_pool.id }
    with[:user_id] = @user.id if @user
        
    scope = case params[:filter]
              when "approved"
                :sphinx_approved
              when "rejected"
                :sphinx_rejected
              when "pending"
                :sphinx_submitted
              else
                :sphinx_all
            end
    
    facets = Order.send(scope).facets params[:query], { :facets => [:created_at_yearmonth],
                                                         :star => true, :page => params[:page], :per_page => $per_page,
                                                         :with => with,
                                                         :sort_mode => :extended, :order => "created_at DESC" }

    year = params[:year].to_i
    s, e = ["#{year}01".to_i, "#{year}12".to_i]

    @available_months = if params[:year].blank?
      []
    else
      facets[:created_at_yearmonth].keys.grep(s..e).map{|x| x - (year * 100) }
    end

    @available_years = facets[:created_at_yearmonth].keys.map{|x| (x / 100).to_i }.uniq.sort
                                                        
    h = if not params[:year].blank? and params[:month].blank?
      {:created_at_yearmonth => (s..e)}
    elsif not params[:month].blank?
      month = "%02d" % params[:month].to_i
      {:created_at_yearmonth => "#{year}#{month}".to_i}
    else
      {}
    end

    @entries = facets.for(h)
    @pages = @entries.total_pages
    @total_entries = Order.send(scope).search_count(:with => with.merge(h))
        
    respond_to do |format|
      format.html
    end
  end

  def show
  end
  
  private ##################################################################
  
  def preload
    params[:order_id] ||= params[:id] if params[:id]
    @order = current_inventory_pool.orders.find(params[:order_id]) if params[:order_id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
