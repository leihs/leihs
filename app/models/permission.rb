class Permission < ActiveRecord::Base
  has_many :access_rights
end
