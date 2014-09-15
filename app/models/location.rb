class Location < ActiveRecord::Base

  has_many :items, dependent: :nullify
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
    attributes["building_id"] = nil if attributes["building_id"].blank?
    attributes["room"] = nil if attributes["room"].blank?
    attributes["shelf"] = nil if attributes["shelf"].blank?
    
    record = where(attributes).first
    record ||= create(attributes)
  end

  def to_s
    "#{building} #{room} #{shelf}"
  end

#################################################################

  default_scope { includes(:building) }

#################################################################

  scope :search, lambda { |query|
    sql = all
    return sql if query.blank?
    
    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(arel_table[:room].matches(q).
                      or(arel_table[:shelf].matches(q)).
                      or(Building.arel_table[:name].matches(q)))
    }
    sql.joins(:building)
  }

  def self.filter(params)
    locations = all
    locations = locations.where(id: params[:ids]) if params[:ids]
    locations
  end

end

