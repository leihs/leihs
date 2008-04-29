class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.belongs_to :order_line
      t.integer :quantity
      t.string :name
      t.string :remark
      t.timestamps
    end
  end

  def self.down
    drop_table :options
  end
end
