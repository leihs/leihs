class Language < ActiveRecord::Base
  
  default_scope -> {order(:name)}
  scope :active_languages, -> {where(:active => true)}
  
  validates_uniqueness_of :default, :if => Proc.new { |l| l.default }
  
  def self.default_language 
    Language.where(:default => true).first || Language.first
  end
  
  def self.preferred(accepted_languages)
    default = default_language
    
    return default if accepted_languages.nil?
    
    accepted_languages = accepted_languages.split(",").map { |x| x.strip.split(";").first.split('-').first }.uniq
    return default if accepted_languages.blank?
     
    possible_languages = active_languages.map { |x| x.locale_name.match(/\w{2}/).to_s }
    preferred_languages = accepted_languages & possible_languages
    
    return default if preferred_languages.blank?
    
    preferred_language = active_languages.detect { |x| !!(x.locale_name =~ /^#{preferred_languages.first}/) }
    
    return preferred_language
  end
end

