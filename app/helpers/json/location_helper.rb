module Json
  module LocationHelper

    def hash_for_location(location, with = nil)
      h = {
        id: location.id,
        room: location.room,
        shelf: location.shelf
      }

      h[:building_id] = location.building.id unless location.building.nil?
      
      h
    end

  end
end
