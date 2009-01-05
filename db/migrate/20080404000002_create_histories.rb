class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.string :text, :default => ""
      t.integer :type_const
      t.datetime :created_at, :null => false
      t.references :target, :null => false, :polymorphic => true
      t.belongs_to :user
    end
    foreign_key :histories, :user_id, :users

  end

  def self.down
    drop_table :histories
  end
end
