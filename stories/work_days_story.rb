dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:order, :work_days, :availability_inventory_pool) do
  run_local_story "./text/work_days_story", :type => RailsStory
end