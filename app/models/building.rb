class Building < ActiveRecord::Base
  audited

  has_many :locations, dependent: :restrict_with_exception
  has_many :items, through: :locations

  validates_presence_of :name

  default_scope { order(:name) }

  ########################################################

  def to_s
    "#{name} (#{code})"
  end

  def self.filter(params)
    buildings = search(params[:search_term])
    buildings = buildings.where(id: params[:ids]) if params[:ids]
    buildings
  end

  scope :search, lambda { |query|
                 sql = all
                 return sql if query.blank?

                 query.split.each do |q|
                   q = "%#{q}%"
                   sql = sql.where(arel_table[:name].matches(q)
                                       .or(arel_table[:code].matches(q))
                                  )
                 end
                 sql
  }

end
