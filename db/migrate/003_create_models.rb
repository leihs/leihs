class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.string :name
      t.string :manufacturer
      t.integer :maintenance_period, :default => 0
      t.timestamps
    end

# TODO remove
#    create_table :models_packages, :id => false do |t|
#      t.belongs_to :model
#      t.belongs_to :package
#    end
#    add_index(:models_packages, :model_id)
#    add_index(:models_packages, :package_id)

# TODO remove ?
    create_table :models_compatibles, :id => false do |t|
      t.belongs_to :model
      t.belongs_to :compatible
    end
    add_index(:models_compatibles, :model_id)
    add_index(:models_compatibles, :compatible_id)
  
  end

  def self.down
    drop_table :models
#    drop_table :models_packages
  end
end

