ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'

dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/steps/*.rb")].uniq.each do |file|
  require file
end

##
# Run a story file relative to the stories directory.

def run_local_story(filename, options={})
  run File.join(File.dirname(__FILE__), filename), options
end

def link2(attributes)
  "<a href='#{attributes['url']}'>#{attributes['name']}</a>"
end


def find_line(model)
  id = 0
  @order.order_lines.each do |line|
    if model == line.model.name
      return line
    end
  end
  nil
end
