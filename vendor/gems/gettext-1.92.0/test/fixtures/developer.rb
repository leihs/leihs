class Developer < ActiveRecord::Base
  N_("Developer|Non existent")
  validates_inclusion_of :salary, :in => 50000..200000
  validates_length_of    :name, :within => 3..20
end
