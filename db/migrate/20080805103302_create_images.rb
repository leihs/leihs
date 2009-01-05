class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.belongs_to :model

      #TODO t.boolean :is_main, :default => false
      
      ### attachment_fu
      t.string  :content_type
      t.string  :filename
      t.integer :size
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string  :thumbnail 
      ###

      t.timestamps
    end

    foreign_key :images, :model_id, :models

  end

  def self.down
    drop_table :images
  end
end
