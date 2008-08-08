dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:inventory) do
  run_local_story "./text/inventory_story", :type => RailsStory
end