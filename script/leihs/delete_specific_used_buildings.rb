# run with "rails runner -e production PATH_TO_THIS_FILE"
# WARNING: USE AT YOUR OWN RISK!!!

$logger = Logger.new(File.join('/tmp', 'delete_used_buildings.log'))
$logger.level = Logger::INFO

def log(log_level = 'info', message = '', stdout = false)
  $logger.send(log_level, message)
  puts message if stdout == true
end

###################### SCOPE ####################################
buildings_ids = [40,
                 6,
                 7,
                 41,
                 8,
                 37,
                 9,
                 15,
                 14,
                 63,
                 42,
                 43,
                 16,
                 35,
                 50,
                 22,
                 57,
                 58,
                 60,
                 55,
                 28]

used_buildings = Building.where(id: buildings_ids)
#################################################################

number_to_be_deleted = used_buildings.count
log :info, "number of buildings to be deleted: #{number_to_be_deleted}", true

not_destroyed_buildings = []
items_with_not_updated_note = []
items_with_not_nullified_location = []

used_buildings.each do |building|
  begin
    dependent_items = building.locations.map(&:items).flatten

    dependent_items.each do |item|
      old_location_info = \
        "Früherer Standort: #{[item.location.building.name, item.location.room, item.location.shelf].compact.join(', ')}"
      begin
        item.update_attribute(:note, [old_location_info, item.note].compact.join("\n\n"))
      rescue => e
        log :error, "Could not update note information for item_id #{item.id}", true
        items_with_not_updated_note << item
      end

      begin
        item.update_attribute(:location, nil)
      rescue => e
        log :error, "Could not nullify location info for item_id #{item.id}", true
        items_with_not_nullified_location << item
      end
    end
    log :info, "updated location information on #{dependent_items.count} dependent items for building_id #{building.id}", true

    number_of_dependent_locations = building.locations.count
    building.locations.destroy_all
    log :info, "deleted #{number_of_dependent_locations} dependent locations for building_id #{building.id}", true

    building.destroy!
    log :info, "deleted building: #{building} with id #{building.id}", true
  rescue => e
    log :error, e.message, true
  end
end

not_destroyed_buildings = Building.where(id: buildings_ids)

log :info, "deleted #{number_to_be_deleted - not_destroyed_buildings.count} out of #{number_to_be_deleted} used buildings", true
if not_destroyed_buildings.length > 0
  log :info,
      "following #{not_destroyed_buildings.length} buildings could not be destroyed: " \
      "#{not_destroyed_buildings.map(&:id)}",
      true
end
if items_with_not_updated_note.length > 0
  log :info,
      "note on the following #{items_with_not_updated_note.length} items could not be updated" \
      "#{items_with_not_updated_note.map(&:id)}",
      true
end
if items_with_not_nullified_location.length > 0
  log :info,
      "location on the following #{items_with_not_nullified_location.length} items could not be nullified" \
      "#{items_with_not_nullified_location.map(&:id)}",
      true
end
