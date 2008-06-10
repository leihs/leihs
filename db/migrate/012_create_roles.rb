class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      #t.timestamps
    end

    Role.create(:name => "inventory_manager")


  end

  def self.down
    drop_table :roles
  end
end
