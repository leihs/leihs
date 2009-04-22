dir = File.dirname(__FILE__)

require dir + "/helper"

with_steps_for(:availability, :inventory, :login) do
  run_local_story "./text/availability_story", :type => RailsStory
end