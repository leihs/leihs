require File.dirname(__FILE__) + "/helper"

with_steps_for(:acknowledge) do
  run_local_story "acknowledge_story", :type => RailsStory
end