class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title, :default => "", :null => false
      t.text :description, :default => "", :null => false
      t.date :lastupdate
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
