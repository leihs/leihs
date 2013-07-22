# A Visit is an event on a particular date, on which a specific
# customer should come to pick up or return items - or from the other perspective:
# when an inventory pool manager should hand over some items to or get them back from the customer.
#
# 'action' says if we want to have hand_overs or take_backs. action can be either of those two:
# * "hand_over"
# * "take_back"
#
# Reading a MySQL View
class Visit < ActiveRecord::Base
  include LineModules::GroupedAndMergedLines
  self.primary_key = :id

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
  
  belongs_to :user
  belongs_to :inventory_pool
  
  has_many :visit_lines
  has_many :contract_lines, :through => :visit_lines
  alias :lines :contract_lines

#  def line_ids
#    contract_line_ids.split(',').map(&:to_i)
#  end
#  def contract_lines
#    @contract_lines ||= ContractLine.includes(:model).find(line_ids)
#  end

  #######################################################
  
  scope :hand_over, lambda { where(:status_const => Contract::UNSIGNED) }
  scope :take_back, lambda { where(:status_const => Contract::SIGNED) }

  #######################################################

  scope :search, lambda { |query|
    sql = scoped
    return sql if query.blank?

    # TODO search on contract_lines' models and items
    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(User.arel_table[:login].matches(q).
                      or(User.arel_table[:firstname].matches(q)).
                      or(User.arel_table[:lastname].matches(q)).
                      or(User.arel_table[:badge_id].matches(q)))
    }
    sql.joins(:user)
  }

  #######################################################

  # compares two objects in order to sort them
  # def <=>(other)
    # self.date <=> other.date
  # end  

  def is_overdue
    date < Date.today
  end

end
