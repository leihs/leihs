class CreateLineGroups < ActiveRecord::Migration
  def self.up
    create_table :line_groups do |t|
      t.belongs_to :model_group
      
      t.timestamps
    end
  end

  def self.down
    drop_table :line_groups
  end
end
