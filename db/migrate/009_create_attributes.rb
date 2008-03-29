class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.belongs_to :model

      t.timestamps
    end
  end

  def self.down
    drop_table :attributes
  end
end
