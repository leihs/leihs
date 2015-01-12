# A VisitLine is an event on a particular date, on which a specific
# customer should come to pick up or return items - or from the other perspective:
# when an inventory pool manager should hand over some items to or get them back from the customer.
#
# 'action' says if we want to have hand_overs or take_backs. action can be either of those two:
# * "hand_over"
# * "take_back"
#
# Reading a MySQL View
#
# this class should never be used directly, the main purpose is to provide a join association between visits and contract_lines 
class VisitLine < ActiveRecord::Base
  self.primary_key = :contract_line_id

  #######################################################
  def readonly?
    true
  end
  def delete
    false
  end
  def self.delete_all
    false
  end
  def self.destroy_all
    false
  end
  before_destroy do
    false
  end
  #######################################################
  
  #belongs_to :user
  belongs_to :inventory_pool
  
  belongs_to :visit
  belongs_to :contract_line

end
