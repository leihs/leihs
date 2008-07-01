require File.dirname(__FILE__) + "/helper"

with_steps_for(:inventory) do
  run_local_story "./text/inventory_story", :type => RailsStory
end