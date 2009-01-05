class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.string :name, :null => false
      t.string :manufacturer
      t.string :description
      t.string :internal_description
      t.string :info_url
      t.decimal :rental_price, :precision => 8, :scale => 2
      t.integer :maintenance_period, :default => 0
      t.boolean :is_package, :default => false
      t.timestamps
    end
    add_index :models, :is_package

    create_table :models_compatibles, :id => false do |t|
      t.belongs_to :model
      t.belongs_to :compatible
    end
    add_index(:models_compatibles, :model_id)
    add_index(:models_compatibles, :compatible_id)
  
  end

  def self.down
    drop_table :models
    drop_table :models_compatibles
  end
end

