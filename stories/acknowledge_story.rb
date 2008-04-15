require File.dirname(__FILE__) + "/helper"

FileUtils.remove_dir(File.dirname(__FILE__) + "/../index/test", true)

with_steps_for(:acknowledge) do
  run_local_story "acknowledge_story", :type => RailsStory
end