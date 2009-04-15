namespace :release do 

  desc "Clean up the current directory for release packaging"
  task :clean do
  # remove temp files, change config files so they don't
  # contain any silliness etc.
	
  	puts "Removing Capistrano deployment recipes"
  	`rm -rf config/deploy`
  	`rm -f config/deploy.rb`

  end

end
