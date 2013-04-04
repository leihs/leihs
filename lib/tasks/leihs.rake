namespace :leihs do

  desc "Build the Leihs RDOC HTML Files"
  task :doc do
    `rake doc:app title="Leihs Application Documentation"`
  end

  # TODO :boot or :server_reboot ??
  desc "Application boot (task called after server reboot)"
  task :boot => :environment do
    Rake::Task["thinking_sphinx:start"].invoke
  end
 
  
  desc "Initialize"
  task :init => :environment do
    params = {:all => ENV['items']}
    create_some(params)
  end

  desc "Maintenance"
  task :maintenance => :environment do
    
    puts "Recomputing availability..."
    system "./script/runner Availability::Change.recompute_all"

    puts "Rebuilding sphinx index..."
    Rake::Task["thinking_sphinx:reindex"].invoke

    puts "Maintenance complete ------------------------"    
  end

  desc "Remind users"
  task :remind => :environment do
    puts "Reminding users..."    
    system "./script/runner User.remind_all"

    puts "Remind complete -----------------------------"    
  end

  desc "Deadline soon reminder" 
  task :deadline_soon_reminder => :environment do
    puts "Sending a deadline soon reminder..."
    system "./script/runner User.send_deadline_soon_reminder_to_everybody"
    puts "Deadline soon reminded ----------------------"
  end
  
  desc "Cron: Remind & Maintenance"
  task :cron => [:remind, :maintenance, :deadline_soon_reminder]

  desc "Run cucumber tests. Run leihs:test[0] to only test failed scenarios"
  task :test, :rerun do |t, args|
    # force environment
    RAILS_ENV='test'
    ENV['RAILS_ENV']='test'
    task :environment
    args.with_defaults(:rerun => 1)
    
    puts "Removing log/test.log..."
    system "rm -f log/test.log"

    if args.rerun.to_i > 0
      puts "Removing rerun.txt..."
      system "rm -f rerun.txt"
    end

    Rake::Task["db:reset"].invoke

    # rspec < 2.x is called spec
    system "bundle exec spec -f html:tmp/html/rspec.html -f n spec"

    exit_code = $? >> 8 # magic brainfuck
    raise "Tests failed with: #{exit_code}" if exit_code != 0

    ENV['CUCUMBER_FORMAT'] = 'pretty' unless ENV['CUCUMBER_FORMAT']
    system "bundle exec cucumber"
    exit_code = $? >> 8 # magic brainfuck
    raise "Tests failed with: #{exit_code}" if exit_code != 0
  end

  desc "Recreate DB and reindex" 
  task :reset => :environment  do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["ts:conf"].invoke
    Rake::Task["thinking_sphinx:reindex"].invoke
  end
  
################################################################################################
# Refactoring from Backend::TemporaryController

  def create_some(params = {})
    puts "Initializing #{params[:all]} items ..."
    
    params[:id] = 3
    params[:name] = "model"
    max = params[:all].to_i
    if max > 0
      Importer.new.start(max)
    else
      Importer.new.start
    end
    
    create_some_root_categories

    puts "Complete"
  end


  
################################################################################################
  

  def create_some_root_categories
    video = Category.find_or_create_by_name(:name => 'Video')
    audio = Category.find_or_create_by_name(:name => 'Audio')
    computer = Category.find_or_create_by_name(:name => 'Computer')
    light = Category.find_or_create_by_name(:name => 'Licht')
    foto = Category.find_or_create_by_name(:name => 'Foto')
    other = Category.find_or_create_by_name(:name => 'Anderes')
    stative = Category.find_or_create_by_name(:name => 'Stative')
    
    add_to(video, Category.find_or_create_by_name(:name => 'Video Kamera'))
    add_to(video,  Category.find_or_create_by_name(:name => 'Film Kamera'))
    add_to(video,  Category.find_or_create_by_name(:name => 'Video Kamera Zubehör'))
    add_to(video,  Category.find_or_create_by_name(:name => 'Film Kamera Zubehör'))
    add_to(video,  Category.find_or_create_by_name(:name => 'Video Monitor'))
    add_to(video,  Category.find_or_create_by_name(:name => 'Video Recorder/Player'))
    add_to(video,  Category.find_or_create_by_name(:name => 'Stativ Video/Film/Foto'))
    
    add_to(audio,  Category.find_or_create_by_name(:name => 'Audio Recorder portable'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Audio Recorder/Player'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Kopfhörer'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Lautsprecher/-anlagen'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Mikrofon'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Mikrofon Zubehör'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Verschiedene AV Geräte'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Verstärker'))
    add_to(audio,  Category.find_or_create_by_name(:name => 'Mikrofon Zubehör'))

    add_to(foto,  Category.find_or_create_by_name(:name => 'Dia-/Hellraumprojektor'))
    add_to(foto,  Category.find_or_create_by_name(:name => 'Foto analog'))
    add_to(foto,  Category.find_or_create_by_name(:name => 'Foto digital'))
    add_to(foto,  Category.find_or_create_by_name(:name => 'Foto Zubehör'))
    add_to(foto,  Category.find_or_create_by_name(:name => 'Stativ Video/Film/Foto'))
    
    add_to(light,  Category.find_or_create_by_name(:name => 'Licht/Scheinwerfer'))
    add_to(light,  Category.find_or_create_by_name(:name => 'Licht Stative'))
    add_to(light,  Category.find_or_create_by_name(:name => 'Licht Zubehör'))
    add_to(light,  Category.find_or_create_by_name(:name => 'Elektro Material'))

    add_to(computer,  Category.find_or_create_by_name(:name => 'Desktop Macintosh'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Desktop PC'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Externer Massenspeicher'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'IT-Display'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'IT-Zubehör'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Notebook'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'PowerBook'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Scanner/Lesegerät'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Server'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Netzwerkkomponente'))
    add_to(computer,  Category.find_or_create_by_name(:name => 'Andere Hardware'))

    add_to(other, Category.find_or_create_by_name(:name => 'DVD - Recorder/Player'))
    add_to(other, Category.find_or_create_by_name(:name => 'Medien-Rack/-Wagen'))
    add_to(other, Category.find_or_create_by_name(:name => 'Andere Hardware'))
    add_to(other, Category.find_or_create_by_name(:name => 'Leinwand'))
    add_to(other, Category.find_or_create_by_name(:name => 'Set-/Bühnenbau'))
    
    add_to(stative, Category.find_or_create_by_name(:name => 'Licht Stative'))
    add_to(stative, Category.find_or_create_by_name(:name => 'Stativ Video/Film/Foto'))
    
  end

  def add_to(parent, sub)
    ModelGroupLink.create_edge(parent, sub)
    sub.set_label(parent, sub.name)
  end
  
  
end
