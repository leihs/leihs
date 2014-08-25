class PolymorphicImages < ActiveRecord::Migration
  def change

    change_table :images do |t|
      t.belongs_to :target, polymorphic: true
      t.index [:target_id, :target_type]
    end

    execute("UPDATE images SET target_id=model_id, target_type='Model'")
    remove_column :images, :model_id

  end
end
