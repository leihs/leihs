# == Schema Information
#
# Table name: roles
#
#  id        :integer(4)      not null, primary key
#  parent_id :integer(4)
#  lft       :integer(4)
#  rgt       :integer(4)
#  name      :string(255)
#  delta     :boolean(1)      default(TRUE)
#

class Role < ActiveRecord::Base
#  has_many :access_rights
#  has_and_belongs_to_many :users

  acts_as_nested_set

  def to_s
    "#{name}"
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name.casecmp other.name
  end

end

