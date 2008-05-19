class Backend::BackendController < ApplicationController
  
  before_filter :init
  
  $theme = '00-patterns'
  $modal_layout_path = 'backend/' + $theme + '/modal'
  $general_layout_path = 'backend/' + $theme + '/general'
  $layout_public_path = "/layouts/00-patterns"
  
  layout $general_layout_path
 

   # add a new line
   def generic_add_line(document, render_id)
    if request.post?
      document.add_line(params[:quantity].to_i, Model.find(params[:model_id]), params[:user_id])
      flash[:notice] = _("Model couldn't be added") unless document.save        
      redirect_to :action => 'show', :id => render_id        
    else
      redirect_to :controller => 'search', 
                  :action => 'model',
                  :id => params[:id],
                  :source_controller => params[:controller],
                  :source_action => params[:action]
    end
  end


  # swap model for a given line
  def generic_swap_model_line(document, render_id)
    if request.post?
      if params[:model_id].nil?
        flash[:notice] = _("Model must be selected")
      else
        document.swap_line(params[:line_id], params[:model_id], session[:user_id])
      end  
      redirect_to :action => 'show', :id => render_id        
    else
      redirect_to :controller => 'search', 
                  :action => 'model',
                  :id => params[:id],
                  :line_id => params[:line_id],
                  :source_controller => params[:controller],
                  :source_action => params[:action]
    end
  end
  
  # change time frame for OrderLines or ContractLines 
  def generic_time_lines(document, render_id)
     if request.post?
      begin
        start_date = Date.new(params[:line]['start_date(1i)'].to_i, params[:line]['start_date(2i)'].to_i, params[:line]['start_date(3i)'].to_i)
        end_date = Date.new(params[:line]['end_date(1i)'].to_i, params[:line]['end_date(2i)'].to_i, params[:line]['end_date(3i)'].to_i)
        params[:lines].each {|l| document.update_time_line(l, start_date, end_date, session[:user_id]) }
      rescue
        flash[:notice] = "Invalid date" #TODO 
      end 
        render :action => 'show', :id => render_id
    else
      @lines = document.lines.find(params[:lines].split(','))
      render :template => 'backend/backend/time_lines', :layout => $modal_layout_path
    end   
  end    
  
  # remove OrderLines or ContractLines
  def generic_remove_lines(document, render_id)
     if request.post?
        params[:lines].each {|l| document.remove_line(l, session[:user_id]) }
        redirect_to :action => 'show', :id => render_id
    else
      @lines = document.lines.find(params[:lines].split(','))
      render :template => 'backend/backend/remove_lines', :layout => $modal_layout_path
    end   
  end    
  
  
  
  private
  
  def init
    @new_orders_size = Order.new_orders.size
    @grouped_lines_size = 999 # TODO

    #TODO define session[:user_id]
  end
  
  def set_order_to_session(order)
    session[:current_order] = { :id => order.id,
                                :user_login => order.user.login }
  end
  
  def remove_order_from_session
    session[:current_order] = nil
  end
  
end
