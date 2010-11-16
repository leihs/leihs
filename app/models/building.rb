# == Schema Information
#
# Table name: buildings
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#  code :string(255)
#

# == Schema Information
#
# Table name: buildings
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#  code :string(255)
#
class Building < ActiveRecord::Base

  def to_s
    "#{name} (#{code})"
  end
end
