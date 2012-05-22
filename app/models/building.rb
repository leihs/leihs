class Building < ActiveRecord::Base
  acts_as_audited
  has_associated_audits
  
  def to_s
    "#{name} (#{code})"
  end
end
