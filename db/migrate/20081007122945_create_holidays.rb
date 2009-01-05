class CreateHolidays < ActiveRecord::Migration
  def self.up
    create_table :holidays do |t|
      t.belongs_to :inventory_pool
      t.date :start_date
      t.date :end_date
      t.string :name
    end

    foreign_key :holidays, :inventory_pool_id, :inventory_pools

  end

  def self.down
    drop_table :holidays
  end
end
