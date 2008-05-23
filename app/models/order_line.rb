class OrderLine < DocumentLine

  belongs_to :order
  
  has_many :options


  
  def self.current_reservations(model_id, date = Date.today)
    find(:all, :conditions => ['model_id = ? and start_date < ? and end_date > ?', model_id, date, date])
  end
  
  def self.future_reservations(model_id, date = Date.today)
    find(:all, :conditions => ['model_id = ? and start_date > ?', model_id, date])
  end
  
  def self.current_and_future_reservations(model_id, order_line_id = 0, date = Date.today)
    find(:all, :conditions => ['model_id = ? and ((start_date < ? and end_date > ?) or start_date > ?) and id <> ?', model_id, date, date, date, order_line_id])
  end

  def self.ready_for_contract
    find_by_sql("SELECT u.id AS user_id,
                         u.login AS user_login,
                         sum(ol.quantity) AS quantity,
                         ol.start_date
                    FROM order_lines ol JOIN orders o ON ol.order_id = o.id
                                        JOIN users u ON o.user_id = u.id
                    WHERE o.status_const = #{Order::APPROVED}
                    GROUP BY ol.start_date, u.id 
                    ORDER BY ol.start_date, u.id") 
  end


end
