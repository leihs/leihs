class Property < ActiveRecord::Base

  belongs_to :model
  # TODO belongs_to :key

  validates_presence_of :key, :value

  def to_s
    "%s: %s" % [key, value]
  end

end

