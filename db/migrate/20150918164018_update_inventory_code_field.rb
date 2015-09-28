class UpdateInventoryCodeField < ActiveRecord::Migration
  def change

    if field = Field.find_by(id: :inventory_code)
      field.data[:forPackage] = true
      field.save
    end

  end
end
