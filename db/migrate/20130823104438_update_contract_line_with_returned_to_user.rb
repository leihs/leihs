class UpdateContractLineWithReturnedToUser < ActiveRecord::Migration
  def change
    change_table(:contract_lines) do |t|
      t.belongs_to :returned_to_user
    end
  end
end
