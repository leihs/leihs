class Role < ActiveRecord::Base
#  has_many :access_rights
#  has_and_belongs_to_many :users

  acts_as_nested_set

  acts_as_ferret :fields => [ :name ]

  def to_s
    "#{name}"
  end

end
