class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload

  def index
    with = { :inventory_pool_id => current_inventory_pool.id }
    with[:user_id] = @user.id if @user

    scope = case params[:filter]
              when "unsigned"
                :sphinx_unsigned
              when "signed"
                :sphinx_signed
              when "closed"
                :sphinx_closed
              else
                :sphinx_all
            end

    # TODO discard contracts without contract_lines (with quantity=0)
    facets = Contract.send(scope).facets params[:query], { :facets => [:created_at_yearmonth],
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
    @total_entries = Contract.send(scope).search_count(:with => with.merge(h))

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
