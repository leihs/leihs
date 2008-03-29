class Contract < ActiveRecord::Base

  belongs_to :user
  has_many :contract_lines

end
