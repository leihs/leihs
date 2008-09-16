class Backup::Order < ActiveRecord::Base

  attr_protected :created_at

  set_table_name "backup_orders"

  belongs_to :order
  has_many :order_lines, :class_name => "Backup::OrderLine" 


end
