require 'active_record'
require 'active_record/fixtures'

ActiveRecord::Base.logger = Logger.new(File.join(RAILS_ROOT, 'test.log'))
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Base.logger.info "In active_record.rb"

# Load the database.yml from #{plugin_path}/test/config if it exists
if file = PTK::Configuration.find_path(:database)

  ActiveRecord::Base.logger.info "Loading database.yml"
  config = YAML::load_file(file)
  ActiveRecord::Base.establish_connection(config['test'])

  # Load a schema if it exists
  if schema = PTK::Configuration.find_path(:schema)

    ActiveRecord::Base.logger.info "Loading schema.rb"
    load(schema)

    # Setup fixtures if the directory exists
    if fixtures = PTK::Configuration.find_path(:fixtures)

      PTK::LoadPath.add fixtures

      Test::Unit::TestCase.fixture_path = fixtures
      Test::Unit::TestCase.use_instantiated_fixtures  = false

    end
  else
    ActiveRecord::Base.logger.info "Not loading schema.rb"
  end
else
  ActiveRecord::Base.logger.info "Not loading database.yml"
end