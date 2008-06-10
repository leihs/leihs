class Backend::BackendController < ApplicationController
  #override# require_role "inventory_manager" #, :for_all_except => [:create_some, # TODO for temporary_controller
                                   #                     :login, :switch_inventory_pool] # TODO for rspec tests
  
  before_filter :init, :except => :create_some # TODO for temporary_controller  # TODO not needed for modal layout
  
  $theme = '00-patterns'
  $modal_layout_path = 'backend/' + $theme + '/modal'
  $general_layout_path = 'backend/' + $theme + '/general'
  $layout_public_path = "/layouts/00-patterns"
  
  layout $general_layout_path
 
###############################################################  
   # add a new line
   def generic_add_line(document, render_id)
    if request.post?
      params[:quantity] ||= 1
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
###############################################################  

  protected

    # TODO temp
    def current_user_and_inventory
      [current_user, current_inventory_pool]
    end
    
    # Accesses the current inventory pool from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_inventory_pool
      @current_inventory_pool ||= InventoryPool.find(session[:inventory_pool_id]) if session[:inventory_pool_id] and not @current_inventory_pool == false
    end

    # Store the given inventory pool id in the session.
    def current_inventory_pool=(new_inventory_pool)
      session[:inventory_pool_id] = new_inventory_pool ? new_inventory_pool.id : nil
      @current_inventory_pool = new_inventory_pool || false
    end  
  
  private
  
  def init
    @current_inventory_pool = current_inventory_pool

    @new_orders_size = Order.new_orders.size 
    @new_contracts_size = ContractLine.ready_for_hand_over.size #Contract.new_contracts.size
    @signed_contracts_size = ContractLine.ready_for_take_back.size #Contract.signed_contracts.size
    @remind_contracts_size = ContractLine.ready_for_remind.size
    
  end
  
  def set_order_to_session(order)
    session[:current_order] = { :id => order.id,
                                :user_login => order.user.login }
  end
  
  def remove_order_from_session
    session[:current_order] = nil
  end
  
end
