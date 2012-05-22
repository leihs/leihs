class Location < ActiveRecord::Base
  acts_as_audited :associated_with => :building

  has_many :items
  belongs_to :building

  validates_uniqueness_of :building_id, :scope => [:room, :shelf]

#temp# 1108**
#  before_save do |record|
#    attributes[:building_id] = nil if attributes[:building_id].blank?
#    attributes[:room] = nil if attributes[:room].blank?
#    attributes[:shelf] = nil if attributes[:shelf].blank?
#  end

  def self.find_or_create(attributes = {})
    attributes.delete(:id)
    attributes.delete("id")
    attributes[:building_id] = nil if attributes[:building_id].blank?
    attributes[:room] = nil if attributes[:room].blank?
    attributes[:shelf] = nil if attributes[:shelf].blank?
    
    record = where(attributes).first
    record ||= create(attributes)
  end

  def to_s
    "#{building} #{room} #{shelf}"
  end

#################################################################

  default_scope includes(:building)

#################################################################

  def self.search2(query)
    return scoped unless query

    w = query.split.map do |x|
      s = []
      s << "CONCAT_WS(' ', room, shelf) LIKE '%#{x}%'"
      s << "buildings.name LIKE '%#{x}%'"
      "(%s)" % s.join(' OR ')
    end.join(' AND ')
    
    joins(:building).where(w)
  end

  def self.filter2(options)
    sql = select("DISTINCT locations.*")
    options.each_pair do |k,v|
      case k
        when :inventory_pool_id
          sql = sql.joins(:items).where(:items => {k => v})
      end
    end
    sql
  end

#################################################################

end

