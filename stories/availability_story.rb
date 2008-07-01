require File.dirname(__FILE__) + "/helper"

with_steps_for(:availability, :inventory) do
  run_local_story "./text/availability_story", :type => RailsStory
end