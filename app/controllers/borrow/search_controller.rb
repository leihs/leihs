class Borrow::SearchController < Borrow::ApplicationController
  
  def search
    search_term = CGI::escape params[:search_term]
    respond_to do |format|
      format.json 
      format.html do 
        @bread_crumbs.add "#{params[:search_term]}", borrow_search_results_path(:search_term => search_term), :search => true
        redirect_to borrow_search_results_path({:search_term => search_term}.merge(@bread_crumbs.to_params))
      end
    end
  end

  def results
    @search_term = CGI::escape params[:search_term]
    @models = Model.filter params, @category, current_user
    set_pagination_header(@models)
    respond_to do |format|
      format.json 
      format.html { @inventory_pools = current_user.inventory_pools.order(:name) }
    end
  end

end
