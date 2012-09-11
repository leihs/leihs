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
  end
end