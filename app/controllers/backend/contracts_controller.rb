class Backend::ContractsController < Backend::BackendController
  
  before_filter do
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end

######################################################################

  def index(filter = params[:filter],
            query = params[:query],
            year = params[:year].to_i,
            month = params[:month].to_i,
            page = params[:page],
            paginate = params[:paginate].try{|x| x == "false" ? false : true})
            
    conditions = { :inventory_pool_id => current_inventory_pool.id }
    conditions[:user_id] = @user.id if @user

    scope = case filter
              when "submitted_or_approved_or_rejected"
                :submitted_or_approved_or_rejected
              when "pending"
                :submitted
              when "approved"
                :approved
              when "rejected"
                :rejected
              when "signed_or_closed"
                :signed_or_closed
              when "signed"
                :signed
              when "closed"
                :closed
              else
                nil
            end

    sql = Contract.where(conditions)
    sql = sql.send(scope) if scope
    search_sql = sql.search(query)

    time_range = if not year.zero? and month.zero?
      "YEAR(contracts.created_at) = %d" % year
    elsif not year.zero?
      "YEAR(contracts.created_at) = %d AND MONTH(contracts.created_at) = %d" % [year, month]
    else
      {}
    end

    @contracts = search_sql.where(time_range).order("contracts.created_at DESC")
    @contracts = @contracts.paginate(:page => page, :per_page => PER_PAGE) if paginate != false

    respond_to do |format|
      format.html {
        @total_entries = sql.where(time_range).count
        @available_months = unless year.zero?
                              []
                            else
                              # OPTIMIZE: DISTINCT instead of .uniq
                              search_sql.select("MONTH(contracts.created_at) AS month").where("YEAR(contracts.created_at) = ?", year).map(&:month).uniq.sort
                            end

        # OPTIMIZE: DISTINCT instead of .uniq
        @available_years = search_sql.select("YEAR(contracts.created_at) AS year").map(&:year).uniq.sort
      }
      format.json { render :json => view_context.json_for(@contracts, {:preset => :contract_minimal}) }
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
