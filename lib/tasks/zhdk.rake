namespace :zhdk do

  desc "Copy the ZHdK production database to the leihs2test instance's database"
  task :production_to_staging do
  
    # These paths are hardcoded for now. Make them configurable if you
    # feel like it.
    production_config = YAML.load_file('/home/rails/leihs/leihs2/database.yml')['production']
    staging_config = YAML.load_file('/home/rails/leihs/leihs2test/database.yml')['production']
    
    if staging_config['database'] =~ /.*prod.*/
      exit_with_production_warning
    end
    
    dump_database(production_config, '/tmp/dump.sql')
    load_database(staging_config, '/tmp/dump.sql')
    
  end


  def exit_with_production_warning
      warning = ''
      warning += "You seem to have a production database configured in the staging\n"
      warning += "configuration file. I won't continue like that. Make sure the\n"
      warning += "target database does not have 'prod' in its name, I will refuse\n"
      warning += "to copy anything to that.\n"
      print_warning(warning, title = '=== ABORT! ===')
      exit 1
  end

  def print_warning(warning, title = '=== WARNING! ===')
     puts "\n\n"
     puts title
     puts warning
     puts title
     puts "\n\n"
  end
  
  def dump_database(config, filename)
  
    `mysqldump -h db.zhdk.ch -u #{config['username']} \
      --password=#{config['password']} \
      #{config['database']} > #{filename}`
    
    if $?.to_i > 0
      print_warning('The dump process did not complete. Exiting without doing anything.')
      exit 1
    end
  end

  def load_database(config, filename)
    `mysql -h db.zhdk.ch -u #{config['username']} \
      --password=#{config['password']} \
      #{config['database']} < #{filename}`
      
    if $?.to_i > 0
      print_warning("Could not load database file #{filename}.")
      exit 1
    end
    
    Rake::Task['ts:reindex'].execute
    
  end
  
end
