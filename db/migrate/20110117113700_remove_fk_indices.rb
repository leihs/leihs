class RemoveFkIndices < ActiveRecord::Migration

  # Remove old foreign key remains
  def self.up
    # indices that are named with the old "fk_*" style
    old_style_indices = [ "fk_contract_lines_contract_id",
                          "fk_contract_lines_item_id",
                          "fk_contract_lines_model_id" ]

    # remove indices that are named with old fk_* name
    old_style_indices.each { |index| remove_index :contract_lines, :name => index }

    # use default name for indices
    change_table :contract_lines do |t|
      t.index :contract_id
      t.index :item_id
      t.index :model_id
    end
  end

  def self.down
  end
end
