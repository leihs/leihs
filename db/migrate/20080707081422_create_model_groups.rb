class CreateModelGroups < ActiveRecord::Migration
  def self.up
    create_table :model_groups do |t|
      t.string :type # STI (single table inheritance)
      
      # columns for Package and Category
      t.string :name      
      
      t.timestamps
    end

    create_table :model_groups_models, :id => false do |t|
      t.belongs_to :model_group
      t.belongs_to :model
    end
    add_index(:model_groups_models, :model_group_id)
    add_index(:model_groups_models, :model_id)

    create_table :model_groups_parents, :id => false do |t|
      t.belongs_to :model_group
      t.belongs_to :parent
      t.string  :label
    end
    add_index(:model_groups_parents, :model_group_id)
    add_index(:model_groups_parents, :parent_id)
    
  end

  def self.down
    drop_table :model_groups
    drop_table :model_groups_models
    drop_table :model_groups_parents
  end
end
