class AlterPurposeToText < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.change :purpose, :text 
    end
    
    change_table :orders do |t|
      t.change :purpose, :text 
    end
  end

  def self.down
    change_table :contracts do |t|
      t.change :purpose, :string 
    end
    
    change_table :orders do |t|
      t.change :purpose, :string
    end
  end
end
