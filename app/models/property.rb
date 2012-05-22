class Property < ActiveRecord::Base
  acts_as_audited :associated_with => :model

  belongs_to :model
  # TODO belongs_to :key

  validates_presence_of :key, :value

end

