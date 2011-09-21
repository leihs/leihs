class RefactorLanguagesEnGbAsDefault < ActiveRecord::Migration
  def change
    
    drop_table :languages
    
    create_table :languages, :force => true do |t|
      t.string  :name
      t.string  :locale_name
      t.boolean :default
      t.boolean :active
    end
        
    require("#{Rails.root}/lib/factory.rb")
    Factory.create_default_languages
  end
end
