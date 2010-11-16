# == Schema Information
#
# Table name: backup_order_lines
#
#  id                :integer(4)      not null, primary key
#  model_id          :integer(4)
#  order_id          :integer(4)
#  inventory_pool_id :integer(4)
#  quantity          :integer(4)
#  start_date        :date
#  end_date          :date
#  created_at        :datetime
#  updated_at        :datetime
#

# == Schema Information
#
# Table name: backup_order_lines
#
#  id                :integer(4)      not null, primary key
#  model_id          :integer(4)
#  order_id          :integer(4)
#  inventory_pool_id :integer(4)
#  quantity          :integer(4)
#  start_date        :date
#  end_date          :date
#  created_at        :datetime
#  updated_at        :datetime
#
class Backup::OrderLine < ActiveRecord::Base
  
  set_table_name "backup_order_lines"
  
  belongs_to :order, :class_name => "Backup::Order"
    
end
