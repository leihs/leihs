class ProductVersion < ActiveRecord::Migration
  def change
    change_column :models, :name, :string, after: :manufacturer
    rename_column :models, :name, :product
    add_column    :models, :version, :string, after: :product

    add_column    :options, :manufacturer, :string, after: :inventory_code
    rename_column :options, :name, :product
    add_column    :options, :version, :string, after: :product
  end
end
