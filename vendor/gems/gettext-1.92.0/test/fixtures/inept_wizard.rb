class IneptWizard < Wizard  #ActiveRecord::Base
  validates_uniqueness_of :city
end
