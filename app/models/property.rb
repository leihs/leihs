class Property < ActiveRecord::Base
  audited

  belongs_to :model, inverse_of: :properties
  # TODO belongs_to :key

  validates_presence_of :key, :value

  def to_s
    '%s: %s' % [key, value]
  end

end

