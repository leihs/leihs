class CreatePackagesAndModelsPackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|

      t.timestamps
    end
    
    create_table :models_packages, :id => false do |t|
      t.belongs_to :model
      t.belongs_to :package
    end
    add_index(:models_packages, :model_id)
    add_index(:models_packages, :package_id)

  end

  def self.down
    drop_table :packages
    drop_table :models_packages
  end
end
