class Role < ActiveRecord::Base
#  has_many :access_rights
#  has_and_belongs_to_many :users

  acts_as_nested_set

  acts_as_ferret :fields => [ :name ], :store_class_name => true, :remote => true

  def to_s
    "#{name}"
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name.casecmp other.name
  end

end
