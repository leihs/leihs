namespace :app do

  desc "Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)"
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    `railroad -iv -o doc/diagrams/railroad/models.dot -M`
  end
  
  namespace :db do
    
    desc "Sync local application instance with test servers most recent database dump"
    task :sync do
      puts "1) start syncing database with testserver's..."
      puts "2) connecting to leihs@rails..."
      $cmdin, $cmdout, $cmderr = Open3.popen3("ssh leihs@rails")
      $cmdin.puts("exit")
      count = 0
      $cmdout.each do |line|
        count += 1 if line.include?("\n")
        break if count == 100
      end
      
      puts "3) prepare folder ./db/backups/ ..."
      $cmdin, $cmdout, $cmderr = Open3.popen3("mkdir ./db/backups/")
      count = 0
      $cmdout.each do |line|
        count += 1 if line.include?("\n")
        break if count == 100
      end
            
      puts "4) copy latest database dump to local..."
      $cmdin, $cmdout, $cmderr = Open3.popen3("scp leihs@rails:/tmp/leihs-current.sql ./db/backups/")
      count = 0
      $cmdout.each do |line|
        count += 1 if line.include?("\n")
        break if count == 100
      end
      
      puts "5) import dump into the database..."
      $cmdin, $cmdout, $cmderr = Open3.popen3("/usr/local/mysql/bin/mysql -h localhost -u root leihs2_dev < ./db/backups/leihs-current.sql")
      count = 0
      $cmdout.each do |line|
        count += 1 if line.include?("\n")
        break if count == 100
      end
      
      puts "6) finaly migrate database..."
      $cmdin, $cmdout, $cmderr = Open3.popen3("rake db:migrate")
      count = 0
      $cmdout.each do |line|
        count += 1 if line.include?("\n")
        break if count == 100
      end
      
      puts "---------------"
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