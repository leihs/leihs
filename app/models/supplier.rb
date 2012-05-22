class Supplier < ActiveRecord::Base
  acts_as_audited

  has_many :items
end

