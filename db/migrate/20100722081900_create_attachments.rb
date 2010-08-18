class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.belongs_to :model
      t.boolean :is_main, :default => false
      
      ### attachment_fu
      t.string  :content_type
      t.string  :filename
      t.integer :size
      ###
    end

    foreign_key :attachments, :model_id, :models

  end

  def self.down
    drop_table :attachments
  end
end
