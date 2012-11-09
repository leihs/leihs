class AddHandedOverByUserToContracts < ActiveRecord::Migration
  def change
    change_table :contracts do |t|
      t.belongs_to :handed_over_by_user
    end
  end
end
