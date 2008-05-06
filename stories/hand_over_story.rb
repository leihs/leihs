require File.dirname(__FILE__) + "/helper"

with_steps_for(:hand_over) do
  run_local_story "hand_over_story", :type => RailsStory
end