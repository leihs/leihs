class InventoryPool < ActiveRecord::Base

  has_many :access_rights

  has_many :items
  has_many :models, :through => :items, :uniq => true #, :group => :id

  has_many :orders
  has_many :order_lines, :through => :orders

  has_many :contracts
  has_many :contract_lines, :through => :contracts

  
  def hand_over_visits
    unless @ho_visits  # OPTIMIZE refresh if new contracts become available
      @ho_visits = []
      contracts.new_contracts.each do |c|
        c.lines.each do |l|
          v = @ho_visits.detect { |w| w.user == c.user and w.date == l.start_date }
          unless v
            @ho_visits << Visit.new(c.inventory_pool, c.user, l.start_date, l)
          else
            v.contract_lines << l
          end
        end
      end
      @ho_visits.sort!
    end
    @ho_visits
  end

  def take_back_visits
   @tb_visits ||= take_back_or_remind_visits
  end

  def remind_visits
   @r_visits ||= take_back_or_remind_visits(:remind => true)
  end

  private
  
  def take_back_or_remind_visits(remind = false)
    visits = []
    contracts.signed_contracts.each do |c|
      #temp# c.lines.each do |l|
      if remind
        lines = c.lines.to_remind
      else
        lines = c.lines.to_take_back
      end
      lines.each do |l| #temp#
        v = visits.detect { |w| w.user == c.user and w.date == l.end_date }
        unless v
          visits << Visit.new(c.inventory_pool, c.user, l.end_date, l)
        else
          v.contract_lines << l
        end
      end
    end
    visits.sort!
  end
  
  
end




