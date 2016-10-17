class AddItemIdToAttachments < ActiveRecord::Migration
  def up
    add_reference :attachments, :item, index: true
    add_foreign_key :attachments, :items, name: 'attachments_item_id_fk', on_delete: :cascade
  end

  def down
    remove_foreign_key :attachments, :items
    remove_reference :attachments, :item
  end
end
