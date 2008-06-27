require File.dirname(__FILE__) + "/helper"

with_steps_for(:availability_inventory_pool) do
  run_local_story "./text/availability_inventory_pool_story", :type => RailsStory
end