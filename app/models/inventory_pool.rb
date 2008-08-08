class InventoryPool < ActiveRecord::Base

  has_many :access_rights
  has_many :users, :through => :access_rights

  has_many :locations
  has_many :items, :through => :locations #, :uniq => true
  has_many :models, :through => :items, :uniq => true #, :group => :id

  has_many :orders
  has_many :order_lines #old#, :through => :orders

  has_many :contracts
  has_many :contract_lines, :through => :contracts

  has_many :packages
  
  
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


  def timeline
    events = []
    contract_lines.each do |l|
      events << Event.new(l.start_date, l.end_date, l.model.name)
    end

    xml = Event.wrap(events)
    
    f_name = "/javascripts/timeline/inventory_pool_#{self.id}.xml"
    File.open("public#{f_name}", 'w') { |f| f.puts xml }
    f_name
  end

  def timeline_visits
    events = []
    hand_over_visits.each do |v|
      events << Event.new(v.date, v.date, v.user.login, false)
    end

    take_back_visits.each do |v|
      events << Event.new(v.date, v.date, v.user.login, false, "take_back")
    end

    xml = Event.wrap(events)
    
    f_name = "/javascripts/timeline/inventory_pool_#{self.id}_visits.xml"
    File.open("public#{f_name}", 'w') { |f| f.puts xml }
    f_name
  end

###################################################################################

  private
  
  def take_back_or_remind_visits(remind = false)
    visits = []
    contracts.signed_contracts.each do |c|
      if remind
        lines = c.lines.to_remind
      else
        lines = c.lines.to_take_back
      end
      lines.each do |l|
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




