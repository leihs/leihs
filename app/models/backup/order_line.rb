class Backup::OrderLine < ActiveRecord::Base
  
  set_table_name "backup_order_lines"
  
  belongs_to :order, :class_name => "Backup::Order"
  belongs_to :line_group, :class_name => "Backup::LineGroup"
  
###############################################  
  
  named_scope :in_group, :conditions => ['line_group_id IS NOT NULL']
  named_scope :not_in_group, :conditions => ['line_group_id IS NULL']

###############################################  
    
end
