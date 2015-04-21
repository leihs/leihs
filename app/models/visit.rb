# A Visit is an event on a particular date, on which a specific
# customer should come to pick up or return items - or from the other perspective:
# when an inventory pool manager should hand over some items to or get them back from the customer.
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

  has_many :reservations, -> (r){ if r.status == :approved
                                      where(start_date: r.date)
                                    else
                                      where(end_date: r.date)
                                    end.where(inventory_pool_id: r.inventory_pool_id, user_id: r.user_id) }, foreign_key: :status, primary_key: :status
  alias :lines :reservations
  def reservation_ids
    reservations.pluck(:id)
  end

  #######################################################

  scope :potential_hand_over, lambda { where(status: :submitted) }
  scope :hand_over, lambda { where(status: :approved) }
  scope :take_back, lambda { where(status: :signed) }
  scope :take_back_overdue, lambda { take_back.where("date < ?", Date.today) }

  #######################################################

  scope :search, lambda { |query|
    sql = where.not(status: :submitted)
    return sql if query.blank?

    # TODO search on reservations' models and items
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
    visits = if inventory_pool.nil?
               all
             else
               inventory_pool.visits
             end.where.not(status: :submitted)
    visits = visits.where(status: params[:status]) if params[:status]
    visits = visits.search(params[:search_term]) unless params[:search_term].blank?
    visits = visits.where arel_table[:date].lteq(params[:date]) if params[:date] and params[:date_comparison] == "lteq"
    visits = visits.where arel_table[:date].eq(params[:date]) if params[:date] and params[:date_comparison] == "eq"

    if r = params[:range]
      visits = visits.where(arel_table[:date].gteq(r[:start_date])) if r[:start_date]
      visits = visits.where(arel_table[:date].lteq(r[:end_date])) if r[:end_date]
    end

    visits = visits.default_paginate params unless params[:paginate] == "false"
    visits
  end

  def action
    case status
      when :submitted
        :potential_hand_over
      when :approved
        :hand_over
      when :signed
        :take_back
    end
  end

  def status
    read_attribute(:status).to_sym
  end

end
