class Supplier < ActiveRecord::Base

  has_many :items

  def to_s
    name
  end
end

