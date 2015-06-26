class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields, id: false do |t|
      t.primary_key :id, :string, limit: 50
      t.text :data # serialized
      t.boolean :active, default: true
      t.integer :position
    end

    execute 'ALTER TABLE fields ADD PRIMARY KEY (id)'

    change_table :fields do |t|
      t.index :active
    end
  end
end
