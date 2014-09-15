namespace :app do

  desc "Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)"
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    `railroad -iv -o doc/diagrams/railroad/models.dot -M`
  end

  namespace :db do

    desc "Sync local application instance with test servers most recent database dump"
    task :sync do
      puts `mkdir ./db/backups/`
      puts `rsync -avuz leihs@rails.zhdk.ch:/tmp/leihs-current.sql ./db/backups/`

      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke

      puts `mysql -h localhost -u root leihs2_dev < ./db/backups/leihs-current.sql`

      Rake::Task["db:migrate"].invoke
      Rake::Task["leihs:maintenance"].invoke

      puts `RAILS_ENV=test rake db:drop db:create db:migrate`
    end
    
  end

# TODO
#  namespace :db do
#    desc "Dump entire database (Structure and Data)"
#    task :dump do
#    end
#  end
  
end
