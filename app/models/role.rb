class Role < ActiveRecord::Base
#  has_many :access_rights
#  has_and_belongs_to_many :users

  acts_as_nested_set

  def to_s
    "#{name}"
  end

end
