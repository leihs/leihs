dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:order_backup, :order, :login) do
  run_local_story "./text/order_backup_story", :type => RailsStory
end