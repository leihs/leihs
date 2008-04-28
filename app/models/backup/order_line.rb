class Backup::OrderLine < ActiveRecord::Base
  
  set_table_name "backup_order_lines"
  
  belongs_to :order, :class_name => "Backup::Order"
  
    
end
