# run with "rails runner -e production PATH_TO_THIS_FILE"
# WARNING: USE AT YOUR OWN RISK!!!

$logger = Logger.new(File.join('/tmp', 'delete_unused_buildings.log'))
$logger.level = Logger::INFO

def log(log_level = 'info', message = '', stdout = false)
  $logger.send(log_level, message)
  puts message if stdout == true
end

###################### SCOPE ####################################
buildings_ids = [54,
                 29,
                 51,
                 53,
                 45,
                 69,
                 38,
                 44,
                 59,
                 52,
                 73,
                 56,
                 77,
                 23,
                 46,
                 26]

unused_buildings = Building.where(id: buildings_ids)
#################################################################

number_to_be_deleted = unused_buildings.count
log :info, "number of buildings to be deleted: #{number_to_be_deleted}", true

not_destroyed_buildings = []
unused_buildings.each do |building|
  begin
    no_dependent_locations = building.locations.count
    building.locations.destroy_all
    building.destroy!
    log :info, "deleted building: #{building} with id #{building.id}", true
    log :info, "deleted also #{no_dependent_locations} dependent locations", true
  rescue => e
    not_destroyed_buildings << building
    log :error, "building #{building} with id #{building.id} could not be deleted!", true
    log :error, e.message, true
  end
end

log :info, "deleted #{number_to_be_deleted - not_destroyed_buildings.count} out of #{number_to_be_deleted} unused buildings", true
if not_destroyed_buildings.length > 0
  log :info,
      "following #{not_destroyed_buildings.length} buildings could not be destroyed: " \
      "#{not_destroyed_buildings.map(&:id)}",
      true
end
