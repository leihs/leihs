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
  include DefaultPagination

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
  
  scope :hand_over, lambda { where(:status => :approved) }
  scope :take_back, lambda { where(:status => :signed) }
  scope :take_back_overdue, lambda { take_back.where("date < ?", Date.today) }

  #######################################################

  scope :search, lambda { |query|
    sql = all
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

  def self.filter(params, inventory_pool = nil)
    visits = inventory_pool.nil? ? all : inventory_pool.visits
    visits = visits.where Visit.arel_table[:action].eq(params[:type]) if params[:type]
    visits = visits.where(:action => params[:actions]) if params[:actions]
    visits = visits.search(params[:search_term]) unless params[:search_term].blank?
    visits = visits.where Visit.arel_table[:date].lteq(params[:date]) if params[:date] and params[:date_comparison] == "lteq"
    visits = visits.where Visit.arel_table[:date].eq(params[:date]) if params[:date] and params[:date_comparison] == "eq"

    if r = params[:range]
      visits = visits.where(Visit.arel_table[:date].gteq(r[:start_date])) if r[:start_date]
      visits = visits.where(Visit.arel_table[:date].lteq(r[:end_date])) if r[:end_date]
    end

    visits = visits.default_paginate params unless params[:paginate] == "false"
    visits
  end

  #######################################################

  # compares two objects in order to sort them
  # def <=>(other)
    # self.date <=> other.date
  # end  

  def status
    read_attribute(:status).to_sym
  end

end
