class Manage::SearchController < Manage::ApplicationController

  before_filter :except => [:search] do
    @search_term = CGI::unescape params[:search_term]
  end

  def search
    search_term = CGI::escape params[:search_term]
    redirect_to manage_search_results_path(current_inventory_pool, {:search_term => search_term})
  end

  def results
  end

  def models
  end

  def items
  end

  def users
  end

  def contracts
  end

  def orders
  end

  def options
  end

end
