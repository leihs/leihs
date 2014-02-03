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

  end
end