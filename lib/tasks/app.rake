namespace :app do

  desc "Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)"
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    `railroad -iv -o doc/diagrams/railroad/models.dot -M`
  end

  desc "Run cucumber tests. Run leihs:test[0] to only test failed scenarios"
  task :test => 'test:run_all'

  namespace :test do

    task :setup do
      # force environment
      Rails.env = 'test'
      RAILS_ENV='test'
      ENV['RAILS_ENV']='test'
      task :environment
      
      puts "Removing log/test.log..."
      system "rm -f log/test.log"

      File.delete("tmp/rerun.txt") if File.exists?("tmp/rerun.txt")

      Rake::Task["leihs:reset"].invoke
    end

    task :run_all do
      Rake::Task["app:test:setup"].invoke
      Rake::Task["app:test:rspec"].invoke
      Rake::Task["app:test:cucumber:all"].invoke
    end

    task :rspec do
      system "bundle exec rspec --format d --format html --out tmp/html/rspec.html spec"
      exit_code = $? >> 8 # magic brainfuck
      raise "Tests failed with: #{exit_code}" if exit_code != 0
    end

    namespace :cucumber do
      task :all do
        ENV['CUCUMBER_FORMAT'] = 'pretty' unless ENV['CUCUMBER_FORMAT']
        # We skip the tests that broke due to the new UI. We need to re-implement them with the new UI.
        system "bundle exec cucumber -p all"
        exit_code_first_run = $? >> 8 # magic brainfuck

        system "bundle exec cucumber -p rerun"
        exit_code_rerun = $? >> 8

        raise "Tests failed!" if exit_code_rerun != 0
      end
    end
  end


  namespace :db do

    desc "Sync local application instance with test servers most recent database dump"
    task :sync do
      puts "Syncing database with testserver's..."
      
      commands = []
      commands << "mkdir ./db/backups/"
      commands << "scp leihs@rails:/tmp/leihs-current.sql ./db/backups/"
      commands << "rake db:drop db:create"
      commands << "mysql -h localhost -u root leihs2_dev < ./db/backups/leihs-current.sql"
      commands << "rake db:migrate"
      commands << "rake leihs:maintenance"

      commands.each do |command|
        puts command
        Open3.popen3(command) do |i,o,e,t|
          puts o.read.chomp
        end
      end
      
      puts " DONE"
    end
    
  end
  
# TODO
#  namespace :db do
#    desc "Dump entire database (Structure and Data)"
#    task :dump do
#    end
#  end
  
end