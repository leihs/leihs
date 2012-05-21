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
    conditions[:user_id] = @user.id if @userc

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


    respond_to do |format|
      format.html {
        @total_entries = sql.where(time_range).count
        @contracts = search_sql.where(time_range).order("contracts.created_at DESC").paginate(:page => page, :per_page => $per_page)
      }
    end
  end
  
  def show
    respond_to do |format|
      format.pdf {
        contract = render_to_string(:layout => false , :action => "../contracts/print/show")
        kit = PDFKit.new(contract)
        #kit.stylesheets << '/path/to/css/file'
        send_data(kit.to_pdf, :type => 'application/pdf', :filename => "contract_#{@contract.id}.pdf") and return
      }
		end
  end
  
  def value_list
    respond_to do |format|
      format.pdf {
        if @contract.status_const == Contract::SIGNED or @contract.status_const == Contract::CLOSED
          send_data(render(:template => 'contracts/value_list', :layout => false), :type => 'application/pdf', :filename => "value_list#{@contract.id}.pdf") 
        else       
          send_data(render(:template => 'backend/contracts/value_list', :layout => false), :type => 'application/pdf', :filename => "value_list#{@contract.id}.pdf")
        end
      }
		end
  end
end
