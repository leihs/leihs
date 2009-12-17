class AddInsuranceNumberToItems < ActiveRecord::Migration
  def self.up
   add_column :items, :insurance_number, :string
  end

  def self.down
    remove_column :items, :insurance_number
  end

end
