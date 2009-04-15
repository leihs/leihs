namespace :release do 

  desc "Clean up the current directory for release packaging"
  task :clean do
  # remove temp files, change config files so they don't
  # contain any silliness etc.
	
    puts "Removing Capistrano deployment recipes"
    `rm -rf config/deploy`
    `rm -f config/deploy.rb`

    puts "Renaming critical config files to .sample"
    `mv config/database.yml config/database.yml.sample`
    `mv config/ferret_server.yml config/ferret_server.yml.sample`
    `mv config/mongrel_cluster.yml config/mongrel_cluster.yml.sample`
    
  end

end
