dir = File.dirname(__FILE__)

require dir + "/helper"

Dir[File.expand_path("#{dir}/**/*.rb")].uniq.each do |file|
  require file
end