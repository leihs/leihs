class AddHandOverNotesToModels < ActiveRecord::Migration
  def self.up
    add_column :models, :hand_over_note, :text
  end

  def self.down
    remove_column :models, :hand_over_note
  end
end
