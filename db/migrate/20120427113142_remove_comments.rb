class RemoveComments < ActiveRecord::Migration
  def up
    drop_table :comments
  end

  def down
  end
end
