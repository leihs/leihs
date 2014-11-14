class Workdays < ActiveRecord::Migration
  def change

    change_table :workdays do |t|
      t.integer :reservation_advance_days,  default: 0, null: true
      t.text    :max_visits # serialized
    end

  end
end
