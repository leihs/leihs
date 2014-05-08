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

  def generate_dump
    config = Rails.configuration.database_configuration[Rails.env]
    system "rm -r #{File.join(Rails.root, "features/personas/dumps")}"
    system "mkdir -p #{File.join(Rails.root, "features/personas/dumps")}"
    DatabaseCleaner.clean_with :truncation
    create_all
    cmd1 = "echo \"SET autocommit=0; SET unique_checks=0; SET foreign_key_checks=0;\" > #{dump_file_name}"
    cmd2 = "mysqldump #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil}  #{config['database']} --no-create-db | grep -v 'SQL SECURITY DEFINER' >> #{dump_file_name}"
    cmd3 = "echo \"COMMIT;\" >> #{dump_file_name}"
    puts cmd1, cmd2, cmd3
    system cmd1
    system cmd2
    system cmd3
  end

  def restore_random_dump
    return true if Setting.exists? and User.exists? # the data are already restored, so we prevent to restore again in further steps

    # check whether we need fresh dumps
    if not File.exists?(dump_file_name) or
        not (t = File.mtime(dump_file_name)).today? or
        Dir.glob(File.join(Rails.root, "features/personas", "*.rb")).map {|f| File.mtime(f) }.max > t
      generate_dump
    end

    config = Rails.configuration.database_configuration[Rails.env]
    cmd = "mysql #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil} #{config['database']} < #{dump_file_name}"
    puts cmd

    # we need this variable assignment in order to wait for the end of the system call. DO NOT DELETE !
    dump_restored = system(cmd)
    raise "persona dump not loaded" unless dump_restored

    # ensure the settings are initialized
    Setting.initialize_constants

    dump_restored
  end

  private

  def create_all
    Dir.glob(File.join(Rails.root, "features/personas", "*.rb")).each do |file|
      Persona.create File.basename(file, File.extname(file))
    end
  end

  def dump_file_name
    File.join(Rails.root, "features/personas/dumps", "seed_#{ENV['TEST_RANDOM_SEED']}.sql")
  end

end
