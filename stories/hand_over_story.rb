require File.dirname(__FILE__) + "/helper"

with_steps_for(:hand_over, :login) do
  run_local_story "./text/hand_over_story", :type => RailsStory
end