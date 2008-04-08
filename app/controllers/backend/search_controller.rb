class Backend::SearchController < ApplicationController

  def model
    if request.post?
      @search_result = Model.find(:all, :conditions => {:name => params[:text]})
    end
    render  :layout => 'backend/00-patterns/modal'
  end
  
  def select_model
    if params[:model_id] != nil
      
        puts "Should be redirected"
      redirect_to :controller => 'acknowledge', 
              :action => 'swap_line', 
              :id => params[:id], 
              :order_line_id => params[:order_line_id],
              :model_id => params[:model_id],
              :target => "_top",
              '_method' => :post
              
    else
      puts params[:model_id] +" must be nil"
      render :template => model, :layout => 'backend/00-patterns/modal'
    end
  end
end
