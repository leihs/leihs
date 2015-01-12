class CreateMailTemplates < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
      t.belongs_to :inventory_pool, null: true # NOTE when null, then is system-wide
      t.belongs_to :language
      t.string :name
      t.string :format
      t.text :body
    end
  end
end
