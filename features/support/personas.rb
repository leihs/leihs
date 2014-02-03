module Persona
  extend self
  
  def get(name)
    User.where(:login => name.downcase).first
  end
  
  def create(name)
    name = name.to_s
    if FileTest.exist? "features/personas/#{name.downcase}.rb"
      persona = Persona.get(name)
      if persona.blank?
        require Rails.root+"features/personas/#{name.downcase}.rb"
        Persona.const_get(name.camelize).new
        return Persona.get(name)
      else
        return persona
      end
    else
      raise "Persona #{name} does not exist"
    end
  end

  def create_dumps(n = 10)
    config = Rails.configuration.database_configuration[Rails.env]
    system "rm -r #{File.join(Rails.root, "features/personas/dumps")}"
    system "mkdir -p #{File.join(Rails.root, "features/personas/dumps")}"
    n.times do |i|
      DatabaseCleaner.clean_with :truncation
      srand(Random.new_seed)
      create_all
      cmd= "mysqldump #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil}  #{config['database']} --no-create-db | grep -v 'SQL SECURITY DEFINER' > #{File.join(Rails.root, "features/personas/dumps/personas_#{i}.sql")}"
      puts cmd
      system cmd
    end
  end

  def restore_random_dump
    return true if Setting.exists? and User.exists? # the data are already restored, so we prevent to restore again in further steps

    file = Dir.glob(File.join(Rails.root, "features/personas/dumps", "*.sql")).sample
    config = Rails.configuration.database_configuration[Rails.env]

    cmd = "mysql #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil} #{config['database']} < #{file}"
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

end
