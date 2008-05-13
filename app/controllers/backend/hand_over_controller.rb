class Backend::HandOverController < Backend::BackendController

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
                                              WHERE o.status_const = 2
                                              GROUP BY ol.start_date, u.id 
                                              ORDER BY ol.start_date, u.id") 
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

        @contract.contract_lines << ContractLine.new(:order_line => ol,
                                            :quantity => 1, # TODO do we need it?
                                            :start_date => ol.start_date,
                                            :end_date => ol.end_date) unless ol.has_all_contract_lines?
      end
      
    end
    @contract.contract_lines.sort!
    @contract.save
  end
  

  def contract

    if request.post?
      
      @contract = Contract.find(params[:id])
      @contract.sign
      
      redirect_to :action => 'index'          
    else
      render :layout => $modal_layout_path
    end    
    
  end
  
  
  
  
end
