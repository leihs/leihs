class Backend::SearchController < ApplicationController

  def model
    if request.post?
      #@search_result = Model.find(:all, :conditions => {:name => params[:text]})
      @search_result = Model.find_by_contents(params[:text])
    end
    render  :layout => $modal_layout_path
  end


  def order
    @orders = Order.find_by_contents(params[:search], {}, {:conditions => ["status_const = ?", Order::NEW]})
    if request.post?
      render :partial => 'backend/acknowledge/orders'
    else
      render :controller => 'acknowledge', :action => 'index'
    end
  end    

end
