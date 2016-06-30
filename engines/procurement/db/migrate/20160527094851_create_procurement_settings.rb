class CreateProcurementSettings < ActiveRecord::Migration
  def change
    create_table :procurement_settings do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.index :key, unique: true
    end
  end
end
