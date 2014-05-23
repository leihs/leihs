namespace :app do

  desc "Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)"
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    `railroad -iv -o doc/diagrams/railroad/models.dot -M`
  end

  namespace :db do

    desc "Sync local application instance with test servers most recent database dump"
    task :sync do
      puts "Syncing database with testserver's..."
      
      require 'open3'

      commands = []
      commands << "mkdir ./db/backups/"
      commands << "scp leihs@rails.zhdk.ch:/tmp/leihs-current.sql ./db/backups/"
      commands << "rake db:drop db:create"
      commands << "mysql -h localhost -u root leihs2_dev < ./db/backups/leihs-current.sql"
      commands << "rake db:migrate"
      commands << "rake leihs:maintenance"
      commands << "RAILS_ENV=test rake db:drop db:create db:migrate"

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
