class AddTimeoutMinutesToSettings < ActiveRecord::Migration
  def change

    change_table :settings do |t|
      t.integer :timeout_minutes, default: 30, null: false
    end

  end
end
