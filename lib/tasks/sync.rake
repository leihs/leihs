require 'open3'

task :sync do
  puts "1) start syncing database with testserver's..."
  puts "2) connecting to leihs@rails..."
  $cmdin, $cmdout, $cmderr = Open3.popen3("ssh leihs@rails")
  $cmdin.puts("cd ~/leihs-test/current/db/backups")
  $cmdin.puts("ls -l")
  $cmdin.puts("exit")
  count = 0
  last = ""
  $cmdout.each do |line|
    count += 1 if line.include?("\n")
    last = line unless line.match(/\w+/).blank? 
    break if count == 100
  end
  
  last = last.match(/[\w\.\-\+]+$/)[0]
  
  puts "3) copy latest database dump to local..."
  $cmdin, $cmdout, $cmderr = Open3.popen3("scp leihs@rails:~/leihs-test/current/db/backups/"+last+" ./db/backups")
  count = 0
  $cmdout.each do |line|
    count += 1 if line.include?("\n")
    break if count == 100
  end
  
  puts "4) unzip dump..."
  $cmdin, $cmdout, $cmderr = Open3.popen3("bzip2 -d ./db/backups/"+last)
  count = 0
  $cmdout.each do |line|
    count += 1 if line.include?("\n")
    break if count == 100
  end
  
  last = last.gsub(/\.bz2$/, '')
  
  puts "5) import dump into the database..."
  $cmdin, $cmdout, $cmderr = Open3.popen3("/usr/local/mysql/bin/mysql -h localhost -u root leihs2_dev < ./db/backups/"+last)
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