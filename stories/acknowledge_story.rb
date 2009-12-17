dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:acknowledge, :order, :login) do
  run_local_story "./text/acknowledge_story", :type => RailsStory
end