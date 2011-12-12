# == Schema Information
#
# Table name: languages
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  locale_name :string(255)
#  default     :boolean(1)
#  active      :boolean(1)
#

class Language < ActiveRecord::Base

  default_scope :order => "name"  
  named_scope :active_languages, :conditions => { :active => true }
  
  validates_uniqueness_of :default, :if => Proc.new { |l| l.default }
  
  def self.default_language 
    Language.first(:conditions => { :default => true }) || Language.first
  end
end

