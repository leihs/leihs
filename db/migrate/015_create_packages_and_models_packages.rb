class CreatePackagesAndModelsPackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|

      t.timestamps
    end
    
    create_table :models_packages do |t|
      t.belongs_to :model
      t.belongs_to :package
    end

  end

  def self.down
    drop_table :packages
  end
end
