dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

Dir[File.expand_path("#{dir}/**/*.rb")].uniq.each do |file|
  require file
end