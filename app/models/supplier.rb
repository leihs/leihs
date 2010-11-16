# == Schema Information
#
# Table name: suppliers
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Supplier < ActiveRecord::Base
  has_many :items
end

