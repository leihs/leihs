require File.dirname(__FILE__) + "/helper"

FileUtils.remove_dir(File.dirname(__FILE__) + "/../index/test", true)

with_steps_for(:acknowledge, :login) do
  run_local_story "./text/acknowledge_story", :type => RailsStory
end