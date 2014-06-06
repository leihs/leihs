module Persona
  extend self
  
  def get(name)
    User.where(:login => name.downcase).first
  end
  
  def create(name)
    name = name.to_s
    file_path = File.join(Rails.root, "features/personas/#{name.downcase}.rb")
    if File.exists? file_path
      Persona.get(name) || begin
                              require file_path
                              Persona.const_get(name.camelize).new
                              Persona.get(name)
                            end
    else
      raise "Persona #{name} does not exist"
    end
  end

  def generate_dumps(n = 3)
    ENV['TIMECOP_MODE'] = "freeze"

    config = Rails.configuration.database_configuration[Rails.env]
    dir = File.join(Rails.root, "features/personas/dumps")
    system "rm -r #{dir}"
    system "mkdir -p #{dir}"
    puts "Deleted:   #{dir}"


    DatabaseCleaner.clean_with :truncation
    FactoryGirl.create :setting
    LeihsFactory.create_default_languages
    system "mysqldump #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil}  #{config['database']} --no-create-db | grep -v 'SQL SECURITY DEFINER' > #{minimal_dump_file_name}"
    puts "Generated: #{minimal_dump_file_name}"


    test_datetime = if ENV['TEST_DATETIME']
      n = 1
      ENV['TEST_DATETIME']
    end

    n.times do
      DatabaseCleaner.clean_with :truncation
      Timecop.return

      use_test_datetime(test_datetime || rand(3.years.ago..3.years.from_now).to_time.iso8601)
      create_all

      system "echo \"SET autocommit=0; SET unique_checks=0; SET foreign_key_checks=0;\" > #{dump_file_name}"
      system "mysqldump #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil}  #{config['database']} --no-create-db | grep -v 'SQL SECURITY DEFINER' >> #{dump_file_name}"
      system "echo \"COMMIT;\" >> #{dump_file_name}"
      puts "Generated: #{dump_file_name}"
    end
  end

  def restore_minimal_dump
    config = Rails.configuration.database_configuration[Rails.env]
    cmd = "mysql #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil} #{config['database']} < #{minimal_dump_file_name}"
    puts "Loading #{minimal_dump_file_name}"

    # we need this variable assignment in order to wait for the end of the system call. DO NOT DELETE !
    dump_restored = system(cmd)
    raise "empty dump not loaded" unless dump_restored

    dump_restored
  end

  def restore_random_dump
    config = Rails.configuration.database_configuration[Rails.env]
    cmd = "mysql #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil} #{config['database']} < #{dump_file_name}"
    puts "Loading #{dump_file_name}"

    # we need this variable assignment in order to wait for the end of the system call. DO NOT DELETE !
    dump_restored = system(cmd)
    raise "persona dump not loaded" unless dump_restored

    # ensure the settings are initialized
    Setting.initialize_constants

    dump_restored
  end

  def use_test_datetime(date = nil)
    ENV['TEST_DATETIME'] = date || ENV['TEST_DATETIME'] || get_test_datetime
    srand(ENV['TEST_DATETIME'].gsub(/\D/, '').to_i)
    back_to_the_future(Time.parse(ENV['TEST_DATETIME']))
    puts "\n        ------------------------- TEST_DATETIME=#{ENV['TEST_DATETIME']} -------------------------"
  end

  private

  def create_all
    Dir.glob(File.join(Rails.root, "features/personas", "*.rb")).each do |file|
      Persona.create File.basename(file, File.extname(file))
    end
  end

  def minimal_dump_file_name
    File.join(Rails.root, "features/personas/dumps", "minimal_seed.sql")
  end

  def dump_file_name
    File.join(Rails.root, "features/personas/dumps", "seed_#{ENV['TEST_DATETIME']}.sql")
  end

  def get_test_datetime
    dump_file_name = Dir.glob(File.join(Rails.root, "features/personas/dumps", "seed_*.sql")).sample

    # check whether we need fresh dumps
    cmd = "please run: $ RAILS_ENV=test rake app:test:prepare"
    unless dump_file_name
      raise "Persona dumps not found, %s" % cmd
    end
    # FIXME not working on CI
    #if Dir.glob(File.join(Rails.root, "features/personas", "*.rb")).map {|f| File.mtime(f) }.max > File.mtime(dump_file_name)
    #  raise "Persona dumps are outdated, %s" % cmd
    #end

    dump_file_name.match(/.*seed_(.*)\.sql/).captures.first
  end

end
