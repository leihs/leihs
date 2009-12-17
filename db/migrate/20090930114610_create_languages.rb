class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :locale_name
      t.boolean :default
      t.boolean :active
    end
    
    Language.create(:name => 'Deutsch', :locale_name => 'de_CH', :default => true, :active => true)
    Language.create(:name => 'English', :locale_name => 'en_US', :default => false, :active => true)
    Language.create(:name => 'Castellano', :locale_name => 'es', :default => false, :active => true)

    add_column :users, :language_id, :integer, :default => Language.first.id
  
  end

  def self.down
    remove_column :users, :language_id
    drop_table :languages
  end
end
