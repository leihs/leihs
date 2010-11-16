# == Schema Information
#
# Table name: properties
#
#  id       :integer(4)      not null, primary key
#  model_id :integer(4)
#  key      :string(255)
#  value    :string(255)
#

class Property < ActiveRecord::Base

  belongs_to :model
  # TODO belongs_to :key

  validates_presence_of :key, :value

end

