class AddStatusNoteToItems < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.text :status_note
    end

  end
end
