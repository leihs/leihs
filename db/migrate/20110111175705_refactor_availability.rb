class RefactorAvailability < ActiveRecord::Migration
  def self.up
    change_table :availability_quantities do |t|
      t.text :out_document_lines # serialized
    end
    drop_table :availability_out_document_lines
  end

  def self.down
  end
end
