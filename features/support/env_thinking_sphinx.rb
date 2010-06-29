#sellittf#
require 'cucumber/thinking_sphinx/external_world'
Cucumber::ThinkingSphinx::ExternalWorld.new
Before do
  ThinkingSphinx::Configuration.instance.controller.index
end

