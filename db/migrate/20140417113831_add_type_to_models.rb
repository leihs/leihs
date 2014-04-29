class AddTypeToModels < ActiveRecord::Migration
  def change
    add_column :models, :type, :string, after: :id, default: 'Model', null: false # STI (single table inheritance)

    change_table :models do |t|
      t.index :type
    end
  end
end
