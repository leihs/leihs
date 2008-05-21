class Backend::HandOverController < Backend::BackendController

  before_filter :load_contract, :only => [:add_line, :swap_model_line, :time_lines, :remove_lines]

  def index
#      orders = Order.approved_orders
#      @users = orders.collect {|o| o.user }.uniq
#      @order_lines = orders.collect {|o| o.order_lines }.flatten

      @grouped_lines = OrderLine.find_by_sql("SELECT u.id AS user_id,
                                                   u.login AS user_login,
                                                   sum(ol.quantity) AS quantity,
                                                   ol.start_date
                                              FROM order_lines ol JOIN orders o ON ol.order_id = o.id
                                                                  JOIN users u ON o.user_id = u.id
                                              WHERE o.status_const = #{Order::APPROVED}
                                              GROUP BY ol.start_date, u.id 
                                              ORDER BY ol.start_date, u.id") 
                                              
   # TODO search/filter                                           
                                            
  end

  # generates a new contract and contract_lines for each item
  def show
    user = User.find(params[:id])
    orders = user.orders.approved_orders
    order_lines = orders.collect {|o| o.order_lines }.flatten
    
    @contract = user.get_current_contract
    
    order_lines.each do |ol|
      ol.quantity.times do
        
#        @contract_lines << { :name => ol.model.name, :start_date => ol.start_date, :inventory_code => ''}
#      end
#      ol.contract_lines.each do |cl|
#        @contract_lines << { :name => ol.model.name, :start_date => cl.start_date, :inventory_code => cl.inventory_code}

        @contract.contract_lines << ContractLine.new(:model => ol.model,
                                            :quantity => 1, # TODO do we need it?
                                            :start_date => ol.start_date,
                                            :end_date => ol.end_date) unless ol.contract_generated?
      end
      ol.contract_generated = true
      ol.save
    end
    
    @contract.contract_lines.sort!
    @contract.save
  end
  
  # Creating the definitive contract
  # TODO rename as "to_contract" or "sign_contract"
  def contract
    if request.post?
      @contract = Contract.find(params[:id])
      @contract.sign
      redirect_to :action => 'index'          
    else
      render :layout => $modal_layout_path
    end    
    
  end

  # Changes the line according to the inserted inventory code
  def change_line
    if request.post?
      @contract_line = ContractLine.find(params[:contract_line_id])
      @contract = @contract_line.contract
      #line = @contract.contract_lines.find(params[:contract_line_id])
      required_item_inventory_code = params[:code]
      @contract_line.item = Item.find(:first, :conditions => { :inventory_code => required_item_inventory_code})
      if @contract_line.save
        #change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
        #log_change(change, user_id)
      else
        @contract_line.errors.each_full do |msg|
          @contract.errors.add_to_base msg
        end
      end
      
#     TODO refactor in the Contract model
#      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
#      @contract.save 
    end
  end  

  # TODO Franco working here ==============================
  def assign_inventory_code
    if request.post?
      item = Item.find(:first, :conditions => { :inventory_code => params[:code] })
      model = item.model unless item.nil?
      unless model.nil?
        contract = Contract.find(params[:id])
        contract_line = contract.contract_lines.find(:first,
                                                     :conditions => { :model_id => model.id,
                                                                      :item_id => nil })
        unless contract_line.nil?
          params[:contract_line_id] = contract_line.id.to_s
          change_line
          render :action => 'change_line' and return # TODO
        end
      end
    end
    render :text => "nothing" # TODO
  end

  
  def add_line
    generic_add_line(@contract, @contract.user.id)
  end

  def swap_model_line
    generic_swap_model_line(@contract, @contract.user.id)
  end

  def time_lines
    generic_time_lines(@contract, @contract.user.id)
  end    

  # remove a contract line for a given contract
  def remove_lines
    generic_remove_lines(@contract, @contract.user.id)
  end  


  private
  
  def load_contract
    @contract = Contract.find(params[:id]) if params[:id]
  end


end
