module LanguageFactory
  extend self
  
  def create
    languages = [{:name => "Deutsch", :locale_name => "de-CH"},{:name => "English (UK)", :locale_name => "en-GB"}, {:name => "English (US)", :locale_name => "en-US"}]
    languages.delete_if {|l| Language.find_by_locale_name(l[:locale_name])}
    if languages.empty?
      Language.first
    else
      FactoryGirl.create(:language, :name => languages.first[:name], :locale_name => languages.first[:locale_name])
    end
  end
  
end

FactoryGirl.define do

  factory :language do
    active {true}
    name { Faker::Lorem.words(1).join }
    locale_name { name[0..1].downcase }
    default { Language.find_by_default(true).blank? }
  end
    
end
