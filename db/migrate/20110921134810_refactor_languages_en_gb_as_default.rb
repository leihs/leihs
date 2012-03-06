class RefactorLanguagesEnGbAsDefault < ActiveRecord::Migration
  def change
    
    change_column_default :users, :language_id, nil

    require "#{Rails.root}/features/support/leihs_factory.rb"
    LeihsFactory.create_default_languages
  end
end
