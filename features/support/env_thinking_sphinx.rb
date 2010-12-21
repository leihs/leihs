Cucumber::Rails::World.use_transactional_fixtures = false

# http://freelancing-god.github.com/ts/en/testing.html
require 'cucumber/thinking_sphinx/external_world'
Cucumber::ThinkingSphinx::ExternalWorld.new
