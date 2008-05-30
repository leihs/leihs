class User < ActiveRecord::Base
  validates_length_of :name, :minimum => 10
  validates_presence_of :lastupdate
end
