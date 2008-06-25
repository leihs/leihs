# puts "require path:\n"
# puts ($:).to_yaml

require_dependency 'acts_as_graph'

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
ActiveRecord::Base.class_eval do
  include TammerSaleh::Acts::Graph
end
