class Backup::LineGroup < ActiveRecord::Base

  set_table_name "backup_line_groups"

  has_many :order_lines, :class_name => "Backup::OrderLine" 

end
