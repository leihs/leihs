dir = File.dirname(__FILE__)

require dir + "/helper"

with_steps_for(:inventory) do
  run_local_story "./text/inventory_story", :type => RailsStory
end