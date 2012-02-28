# == Schema Information
#
# Table name: backup_orders
#
#  id                :integer(4)      not null, primary key
#  order_id          :integer(4)
#  user_id           :integer(4)
#  inventory_pool_id :integer(4)
#  status_const      :integer(4)      default(1)
#  purpose           :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  delta             :boolean(1)      default(TRUE)
#

# == Schema Information
#
# Table name: backup_orders
#
#  id                :integer(4)      not null, primary key
#  order_id          :integer(4)
#  user_id           :integer(4)
#  inventory_pool_id :integer(4)
#  status_const      :integer(4)      default(1)
#  purpose           :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  delta             :boolean(1)      default(TRUE)
#
class Backup::Order < ActiveRecord::Base

  attr_protected :created_at

  self.table_name = "backup_orders"

  belongs_to :order
  has_many :order_lines, :class_name => "Backup::OrderLine" 


end
