dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:availability_inventory_pool) do
  run_local_story "./text/availability_inventory_pool_story", :type => RailsStory
end