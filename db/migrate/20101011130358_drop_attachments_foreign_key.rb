class DropAttachmentsForeignKey < ActiveRecord::Migration
  def self.up
    remove_foreign_key_and_add_index :attachments, :model_id
  end

  def self.down
    remove_index_and_add_foreign_key :attachments, :model_id, :models
  end
end
