class AddTechnicalDetailToModel < ActiveRecord::Migration
  def self.up
    add_column :models, :technical_detail, :string
  end

  def self.down
    remove_column :models, :technical_detail
  end
end
