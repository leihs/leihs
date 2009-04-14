desc "Clean up the current directory for release packaging"
task :clean do
# remove temp files, change config files so they don't
# contain any silliness etc.
	
	puts "Removing Capistrano deployment recipes"
	`rm -r config/deploy`
	`rm config/deploy.rb`

end
