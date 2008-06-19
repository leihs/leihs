class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :categories_parents, :id => false do |t|
      t.belongs_to :category
      t.belongs_to :parent
    end
    
  end

  def self.down
    drop_table :categories
    drop_table :categories_parents
  end
end
