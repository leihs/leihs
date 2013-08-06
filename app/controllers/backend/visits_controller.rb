class Backend::VisitsController < Backend::BackendController
    
  def index(filter = params[:filter],
            query = params[:query],
            with = params[:with] || {},
            year = params[:year].to_i,
            month = params[:month].to_i,
            date = params[:date].try{|x| Date.parse(x)},
            paginate = params[:paginate].try{|x| x == "false" ? false : true},
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
    search_sql = sql.search(query)
                            
    time_range = if date
      if date == Date.today
        "visits.date <= '%s'" % date
      else
        "visits.date = '%s'" % date
      end
    elsif not year.zero? and month.zero?
      "YEAR(visits.date) = %d" % year
    elsif not year.zero?
      "YEAR(visits.date) = %d AND MONTH(visits.date) = %d" % [year, month]
    else
      {}
    end

    @visits = search_sql.where(time_range).order("visits.date ASC")
    @visits = @visits.paginate(:page => page, :per_page => Setting::PER_PAGE) if paginate != false

    respond_to do |format|
      format.html {
        @total_entries = sql.where(time_range).count
        @available_months = unless year.zero?
          []
        else
          # OPTIMIZE: DISTINCT instead of .uniq 
          search_sql.select("MONTH(visits.date) AS month").where("YEAR(visits.date) = ?", year).map(&:month).uniq.sort
        end
        # OPTIMIZE: DISTINCT instead of .uniq 
        @available_years = search_sql.select("YEAR(visits.date) AS year").map(&:year).uniq.sort
      }
      format.json { render :json => view_context.json_for(@visits, with.merge({:preset => :visit})) }
    end

  end  

end
