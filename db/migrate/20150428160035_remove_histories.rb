class RemoveHistories < ActiveRecord::Migration
  def change

    drop_table :histories

    add_index :notifications, [:created_at, :user_id]

    MailTemplate.where(name: 'changed').delete_all

  end
end
