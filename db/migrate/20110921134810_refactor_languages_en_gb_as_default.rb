class RefactorLanguagesEnGbAsDefault < ActiveRecord::Migration
  def self.up
    
    change_column_default :users, :language_id, nil
        
    require("#{Rails.root}/lib/factory.rb")
    Factory.create_default_languages
  end
  
  def self.down
  end
  
end
