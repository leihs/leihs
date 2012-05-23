class ChangeModelsColumnsType < ActiveRecord::Migration
  def up
    change_column :models, :description, :text
    change_column :models, :internal_description, :text
    change_column :models, :technical_detail, :text
  end

  def down
    change_column :models, :description, :string
    change_column :models, :internal_description, :string
    change_column :models, :technical_detail, :string
  end
end
