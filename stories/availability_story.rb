dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:availability, :inventory) do
  run_local_story "./text/availability_story", :type => RailsStory
end