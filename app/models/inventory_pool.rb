class InventoryPool < ActiveRecord::Base

  has_many :access_rights
  has_many :users, :through => :access_rights, :uniq => true
########
#  has_many :managers, :through => :access_rights, :source => :user, :join_table => "access_rights", :conditions => ["access_rights.role_id = 2"]
#  has_many :managers, :class_name => "User",
#           :finder_sql => "SELECT DISTINCT u.*
#                            FROM access_rights ar
#                              LEFT JOIN users u
#                                ON ar.user_id = u.id
#                                  LEFT JOIN roles r
#                                    ON ar.role_id = r.id
#                            WHERE ar.inventory_pool_id = #{self.id} 
#                              AND r.name = 'manager'"
  has_and_belongs_to_many :managers,
                          :class_name => "User",
                          :select => "users.*",
                          :join_table => "access_rights",
                          :conditions => ["access_rights.role_id = ?", Role.first(:conditions => {:name => "manager"}).id]
########
      
  has_many :locations
  has_one  :main_location, :class_name => "Location", :conditions => {:main => true}  
  has_many :items, :through => :locations, :uniq => true
  has_many :models, :through => :items, :uniq => true

  has_and_belongs_to_many :accessories

  has_many :orders
  has_many :order_lines #old#, :through => :orders

  has_many :contracts
  has_many :contract_lines, :through => :contracts, :uniq => true


  before_create :assign_main_location

  
  def to_s
    "#{name}"
  end

###################################################################################
  
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
  
  def assign_main_location(location = nil)
    location ||= Location.create(:room => "main")
    #old# self.main_location = location
    location.update_attribute :main, true
    self.locations << location
  end
  
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




