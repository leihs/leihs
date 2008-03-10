require File.dirname(__FILE__) + "/helper"

with_steps_for(:simple) do
  run_local_story "simple_story", :type => RailsStory
end