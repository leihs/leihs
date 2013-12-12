class Building < ActiveRecord::Base

  def to_s
    "#{name} (#{code})"
  end

  def self.filter(params)
    buildings = scoped
    buildings = buildings.where(id: params[:ids]) if params[:ids]
    buildings
  end

end
