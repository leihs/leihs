class Backend::ContractsController < Backend::BackendController
  
  before_filter do
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
  end

######################################################################

  def index(filter = params[:filter],
            query = params[:query],
            year = params[:year].to_i,
            month = params[:month].to_i,
            page = params[:page])
            
    conditions = { :inventory_pool_id => current_inventory_pool.id }
    conditions[:user_id] = @user.id if @user

    scope = case filter
              when "signed"
                :signed
              when "closed"
                :closed
              else
                :signed_or_closed
            end

    # unscoped is for skip de default_scope
    sql = Contract.unscoped.send(scope).where(conditions)
    search_sql = sql.search(query)

    @available_months = unless year.zero?
      []
    else
      # OPTIMIZE: DISTINCT instead of .uniq 
      search_sql.select("MONTH(contracts.created_at) AS month").where("YEAR(contracts.created_at) = ?", year).map(&:month).uniq.sort
    end

    # OPTIMIZE: DISTINCT instead of .uniq 
    @available_years = search_sql.select("YEAR(contracts.created_at) AS year").map(&:year).uniq.sort
                                                        
    time_range = if not year.zero? and month.zero?
      "YEAR(contracts.created_at) = %d" % year
    elsif not year.zero?
      "YEAR(contracts.created_at) = %d AND MONTH(contracts.created_at) = %d" % [year, month]
    else
      {}
    end


    respond_to do |format|
      format.html {
        @total_entries = sql.where(time_range).count
        @contracts = search_sql.where(time_range).order("contracts.created_at DESC").paginate(:page => page, :per_page => PER_PAGE)
      }
    end
  end

  def show
    respond_to do |format|
      format.json {
        render :json => view_context.json_for(@contract.reload, {:preset => :contract})
      }
		end
  end

end
