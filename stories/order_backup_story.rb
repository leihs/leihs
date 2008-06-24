require File.dirname(__FILE__) + "/helper"

with_steps_for(:order) do
  run_local_story "./text/order_backup_story", :type => RailsStory
end