class FieldsUsers < ActiveRecord::Migration
  def change

    create_table :hidden_fields do |t|
      t.string :field_id
      t.belongs_to :user
    end

  end
end
