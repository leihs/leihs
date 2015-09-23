class Supplier < ActiveRecord::Base
  audited

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  has_many :items, dependent: :restrict_with_exception

  def to_s
    name
  end

  def self.filter(params)
    suppliers = search(params[:search_term]).order(:name)
    suppliers = suppliers.where(id: params[:ids]) if params[:ids]
    suppliers
  end

  scope :search, lambda { |query|
                 sql = all
                 return sql if query.blank?

                 query.split.each { |q|
                   q = "%#{q}%"
                   sql = sql.where(arel_table[:name].matches(q))
                 }
                 sql
               }

end

