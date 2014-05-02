class AddHintsToSoftware < ActiveRecord::Migration
  def change
    add_column :models, :hints, :text
  end
end
