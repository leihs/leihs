class ItemLineConsistency < ActiveRecord::Migration
  def self.up
    lines_to_fix = ItemLine.all(:include => :item, :conditions => "contract_lines.model_id != items.model_id")
    
    lines_to_fix.each do |line|
      line.model = line.item.model
      line.save(false)
    end
  end

  def self.down
  end
end
