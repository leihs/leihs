class MergingLocations < ActiveRecord::Migration

  def self.up    
    
    Item.all.each do |i|
       i.update_attributes(:location => Location.find_or_create(i.location.attributes)) if i.location
    end

    Location.all.each do |l|
      l.destroy if l.items.empty?
    end

  end
  
  def self.down
  end
end
