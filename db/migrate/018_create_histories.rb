class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.string :text, :default => ""
      t.integer :type_const
      t.datetime :created_at, :null => false
      t.references :target, :null => false, :polymorphic => true
      t.belongs_to :user
    end
  end

  def self.down
    drop_table :histories
  end
end
