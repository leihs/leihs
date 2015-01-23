class Building < ActiveRecord::Base

  has_many :locations, dependent: :restrict_with_exception
  has_many :items, through: :locations

  validates_presence_of :name

  default_scope { order(:name) }

  ########################################################

  def to_s
    "#{name} (#{code})"
  end

  def self.filter(params)
    buildings = all
    buildings = buildings.where(id: params[:ids]) if params[:ids]
    buildings
  end

end
