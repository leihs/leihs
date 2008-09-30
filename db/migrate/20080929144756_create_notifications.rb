class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.belongs_to :user
      t.string :title, :default => ""
      t.datetime :created_at, :null => false
    end
  end

  def self.down
    drop_table :notifications
  end
end
