class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      #t.timestamps
    end

    create_table :categories_parents, :id => false do |t|
      t.belongs_to :category
      t.belongs_to :parent
      t.string  :label
    end
    add_index(:categories_parents, :category_id)
    add_index(:categories_parents, :parent_id)

    create_table :categories_models, :id => false do |t|
      t.belongs_to :category
      t.belongs_to :model
    end
    add_index(:categories_models, :category_id)
    add_index(:categories_models, :model_id)
    
  end

  def self.down
    drop_table :categories
    drop_table :categories_parents
    drop_table :categories_models
  end
end
