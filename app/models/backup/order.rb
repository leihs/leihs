class Backup::Order < ActiveRecord::Base

  set_table_name "backup_orders"

  belongs_to :order
  has_many :order_lines, :class_name => "Backup::OrderLine" 
  has_many :line_groups, :through => :order_lines, :class_name => "Backup::LineGroup", :uniq => true


end
