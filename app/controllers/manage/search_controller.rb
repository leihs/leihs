class Manage::SearchController < Manage::ApplicationController

  before_action except: [:search] do
    @search_term = CGI::unescape params[:search_term]
  end

  def search
    search_term = CGI::escape params[:search_term]
    redirect_to manage_search_results_path(current_inventory_pool,
                                           search_term: search_term)
  end

  [:results,
   :models,
   :software,
   :items,
   :licenses,
   :users,
   :contracts,
   :orders,
   :options]
    .each { |action| define_method(action) {} }

end
