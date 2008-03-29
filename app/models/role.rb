class Role < ActiveRecord::Base
  has_many :access_rights
end
