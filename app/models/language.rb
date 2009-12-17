class Language < ActiveRecord::Base
  
  named_scope :active_languages, :conditions => { :active => true }
  
  def self.default_language 
    Language.first(:conditions => { :default => true }) || Language.first
  end
  
  
end
