namespace :app do

  namespace :test do

    desc "Test the applications Javascript with Jasmine-Headless-Webkit"
    task :js => :environment do
      puts "[START] Running jasmine-headless-webkit"
      
      require 'open3'

      commands = ["jasmine-headless-webkit"]
      commands.each do |command|
        puts command
        Open3.popen3(command) do |i,o,e,t|
          puts o.read.chomp
        end
      end
      
      puts "[END] finishing jasmine-headless-webkit"
    end

    desc "Generate personas dumps (executed by Domina CI)"
    task :generate_personas_dumps => :environment do
      Persona.create_dumps(3)

      if execution_id = ENV["DOMINA_EXECUTION_ID"]
        `rm -r /tmp/#{execution_id}`
        `mkdir -p /tmp/#{execution_id}`
        `cp -r #{File.join(Rails.root, "features/personas/dumps/personas_*.sql")} /tmp/#{execution_id}`
      end
    end

    task :setup do
      `#{Rails.root}/script/validate_gettext_files.sh`
      if $?.exitstatus != 0
        raise "FATAL: Gettext files did not validate. Exiting."
      end
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
      Rake::Task["app:test:jasmine"].invoke
    end

    task :rspec do
      system "bundle exec rspec --format d --format html --out tmp/html/rspec.html spec"
      exit_code = $?.exitstatus
      raise "Tests failed with: #{exit_code}" if exit_code != 0
    end

    namespace :cucumber do
      task :all do
        ENV['CUCUMBER_FORMAT'] = 'pretty' unless ENV['CUCUMBER_FORMAT']
        # We skip the tests that broke due to the new UI. We need to re-implement them with the new UI.
        system "bundle exec cucumber -p default"
        exit_code_first_run = $?.exitstatus

        if exit_code_first_run != 0
          puts "Non-zero exit necessiates a rerun. Go, go, go!"
          #puts "Non-zero exit WOULD necessiate a rerun. But we are not rerunning at all at the moment since it wastes time."
          #puts "You can still peek at tmp/rerun.txt to see what you COULD rerun, if you like."
          #raise "Tests failed on first run, giving up."
          Rake::Task["app:test:cucumber:rerun"].invoke
        end
      end

      task :rerun do
        rerun_count = 2
        puts "Rerunning up to #{rerun_count + 1} times."
        system "bundle exec cucumber -p rerun"
        exit_code = $?.exitstatus
        if exit_code != 0
          while (rerun_count > 0 and exit_code != 0)
            if File.exists?("tmp/rerun.txt")
              puts "Previous run left a tmp/rerun.txt file. Continuing."
              puts "Maximum #{rerun_count} reruns remaining. Trying to rerun until we're successful."
              if File.exists?("tmp/rererun.txt") and File.stat("tmp/rererun.txt").size > 0 # The 'rererun.txt' file contains some failed examples
                File.rename("tmp/rererun.txt","tmp/rerun.txt")
                system "bundle exec cucumber -p rerun"
                exit_code = $?.exitstatus
                rerun_count -= 1
              end
            else
              puts "Supposed to do a rerun, but no tmp/rerun.txt exists! Doing nothing."
              exit_code = 1 
              rerun_count = 0
            end
          end
        end
        puts "Final rerun exited with #{exit_code}"
        raise "Tests failed during rerun!" if exit_code != 0
      end

    end
  end
end
