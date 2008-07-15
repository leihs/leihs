class CreateLineGroups < ActiveRecord::Migration
  def self.up
    create_table :line_groups do |t|
      t.belongs_to :model_group
      t.integer :quantity, :default => 1
      
      t.timestamps
    end

    # TODO acts_as_backupable
    create_table :backup_line_groups do |t|
      t.belongs_to :model_group
      t.integer :quantity, :default => 1
      
      t.timestamps
    end
  end

  def self.down
    drop_table :line_groups
    drop_table :backup_line_groups
  end
end
