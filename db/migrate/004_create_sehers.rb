class CreateSehers < ActiveRecord::Migration
  def self.up
    create_table :sehers do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :sehers
  end
end
