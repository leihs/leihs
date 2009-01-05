class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.belongs_to :user
      t.string :title, :default => ""
      t.datetime :created_at, :null => false
    end
    foreign_key :notifications, :user_id, :users

  end

  def self.down
    drop_table :notifications
  end
end
