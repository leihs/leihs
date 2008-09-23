class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.string :name, :null => false
      t.string :manufacturer
      t.integer :maintenance_period, :default => 0
      t.timestamps
    end

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

