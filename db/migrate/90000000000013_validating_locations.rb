class ValidatingLocations < ActiveRecord::Migration
  def self.up

    Item.suspended_delta do
      destroyed = []
      Location.all.each do |location|
        next if destroyed.include?(location.id)
        unless location.valid?
          items = []
          
          conflicting_locations = Location.all(:conditions => {:building_id => location.building_id, :room => location.room, :shelf => location.shelf })
          conflicting_locations.sort! {|x,y| y.items.count <=> x.items.count }
          conflicting_locations[1..-1].each do |cl|
            items << cl.items
            cl.destroy
            destroyed << cl.id if cl.destroyed?
          end
  
          items.flatten.each do |i|
            i.update_attributes(:location => conflicting_locations[0])
          end
        end
      end
    end

    remove_foreign_key :contract_lines, :location_id rescue nil
    remove_column(:contract_lines, :location_id)
  end

  def self.down
    add_column(:contract_lines, :location_id, :integer, :null => true, :default => nil)
  end
end
