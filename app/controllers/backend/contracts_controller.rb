class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload

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
    search_sql = sql.search2(query)

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

    @total_entries = sql.where(time_range).count
    @entries = search_sql.where(time_range).order("contracts.created_at DESC").paginate(:page => page, :per_page => $per_page)
    @entries_json = @entries.to_json(:with => {:lines => {:include => :model}, 
                                               :user => {:methods => [:image_url]}},
                                     :methods => :quantity) 
    @pages = @entries.total_pages

    respond_to do |format|
      format.html
    end
  end
  
  def show
    respond_to do |format|
			# Evil hack? We need the contract information in that other template as well
      require 'prawn/measurement_extensions'
      prawnto :prawn => { :page_size => 'A4', 
                          :left_margin => 25.mm,
                          :right_margin => 15.mm,
                          :bottom_margin => 15.mm,
                          :top_margin => 15.mm
                        }
    
			if params[:template] == "value_list"
        
        if @contract.status_const == Contract::SIGNED or @contract.status_const == Contract::CLOSED
          format.pdf { send_data(render(:template => 'contracts/value_list_for_items', :layout => false), :type => 'application/pdf', :filename => "value_list_for_items#{@contract.id}.pdf") }
        else       
          format.pdf { send_data(render(:template => 'backend/contracts/value_list_for_models', :layout => false), :type => 'application/pdf', :filename => "maximum_value_list_#{@contract.id}.pdf") }
        end
      else
      # format.html
        format.pdf { send_data(render(:template => 'contracts/show', :layout => false), :type => 'application/pdf', :filename => "contract_#{@contract.id}.pdf") }
			end
    end
  end

  private
  
  def preload
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
  end
  
end
