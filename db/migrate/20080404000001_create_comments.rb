class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.string :title, :limit => 50
      t.text :comment
      t.datetime :created_at
      t.references :commentable,  :null => false, :polymorphic => true
      t.belongs_to :user
    end
#    add_index :comments, [:commentable_type, :commentable_id]
    foreign_key :comments, :user_id, :users

  end

  def self.down
    drop_table :comments
  end
end

