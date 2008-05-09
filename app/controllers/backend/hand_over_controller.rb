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
    orders = User.find(params[:id]).orders.approved_orders
    @order_lines = orders.collect {|o| o.order_lines }.flatten.sort
    @contract = Contract.new # TODO if doesn't exist
    @order_lines.each do |ol|
      ol.quantity.times do
        @contract.contract_lines << ContractLine.new(:item => ol.model.items.first, #TODO selecting temporary item
                                                     :quantity => 1,
                                                     :start_date => ol.start_date,
                                                     :end_date => ol.end_date)
      end
    end
  end
  
  
end
