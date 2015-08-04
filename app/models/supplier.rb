class Supplier < ActiveRecord::Base
  audited

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  has_many :items, dependent: :restrict_with_exception

  def to_s
    name
  end

  def self.filter(params)
    suppliers = order(:name)
    suppliers = suppliers.where(id: params[:ids]) if params[:ids]
    suppliers
  end

end

