class Backend::VisitsController < Backend::BackendController
    
  def index(filter = params[:filter],
            query = params[:query],
            year = params[:year].to_i,
            month = params[:month].to_i,
            page = params[:page])

    scope = case filter
              when "hand_over"
                :hand_over
              when "take_back"
                :take_back
              else
                :scoped
            end
            
    sql = current_inventory_pool.visits.send(scope)
    search_sql = sql.search2(query)

    @available_months = unless year.zero?
      []
    else
      # OPTIMIZE: DISTINCT instead of .uniq 
      search_sql.select("MONTH(visits.date) AS month").where("YEAR(visits.date) = ?", year).map(&:month).uniq.sort
    end

    # OPTIMIZE: DISTINCT instead of .uniq 
    @available_years = search_sql.select("YEAR(visits.date) AS year").map(&:year).uniq.sort
                                                        
    time_range = if not year.zero? and month.zero?
      "YEAR(visits.date) = %d" % year
    elsif not year.zero?
      "YEAR(visits.date) = %d AND MONTH(visits.date) = %d" % [year, month]
    else
      {}
    end

    respond_to do |format|
      format.html {
        @total_entries = sql.where(time_range).count
        @visits = search_sql.where(time_range).order("visits.date ASC").paginate(:page => page, :per_page => $per_page)
      }
    end

  end  

end
