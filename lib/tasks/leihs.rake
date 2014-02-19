# -*- encoding : utf-8 -*-
require 'net/http'
require 'json'

namespace :leihs do

  desc "Build the Leihs RDOC HTML Files"
  task :doc do
    `rake doc:app title="Leihs Application Documentation"`
  end

  desc "set the deploy information as footer"
  task :set_deploy_information_footer do |branch|
    branch = ENV["BRANCH"]
    sha = File.read(ENV["REVISION_PATH"])

    url = URI.parse("https://api.github.com/repos/zhdk/leihs/commits/#{branch}")
    request = Net::HTTP::Get.new(url.path)

    response = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) {|http| http.request(request)}
    json = JSON.parse response.body
    author = json["commit"]["author"]
    time_of_commit = DateTime.parse(author["date"]).to_s
    time_now = Time.now.to_s
    sha = json["sha"]

    File.open(Rails.root.join("app", "views", "staging", "_deploy_information.html.haml"), 'a+') do |f| 

      f.puts "\n        %span"
      f.print "          = _(\"this is the branch '%s'\")"
      f.print " % \"#{branch}\""

      f.puts "\n        %span"
      f.print "          = _(\"deployed %s ago\")"
      f.print " % distance_of_time_in_words_to_now(\"#{time_now}\")"

      f.puts "\n        %span\n"
      f.print "          = _(\"last change by '%s'\")"
      f.print " % \"#{author["name"]}\"\n"

      f.print "          = _(\"is %s ago\")"
      f.print " % distance_of_time_in_words_to_now(\"#{time_of_commit}\")"
      f.puts "\n        %span\n"
      f.print "          = \"#{sha}\""
    end

    text = File.read(Rails.root.join("app", "views", "staging", "_deploy_information.html.haml"))
    File.open(Rails.root.join("app", "views", "layouts", "splash.html.haml"), 'a+') {|f| f.puts text}
    File.open(Rails.root.join("app", "views", "layouts", "manage.html.haml"), 'a+') {|f| f.puts text}
    File.open(Rails.root.join("app", "views", "layouts", "borrow.html.haml"), 'a+') {|f| f.puts text}
  end

  task :test do
    raise "Please call app:test, not leihs:test. The leihs: namespace is being deprecated."
  end

  desc "Maintenance"
  task :maintenance => :environment do
    
    # nothing to do
    
    puts "Maintenance complete ------------------------"    
  end

  desc "Remind users"
  task :remind => :environment do
    puts "Reminding users..."    
    User.remind_all
    puts "Remind complete -----------------------------"    
  end

  desc "Deadline soon reminder" 
  task :deadline_soon_reminder => :environment do
    puts "Sending a deadline soon reminder..."
    User.send_deadline_soon_reminder_to_everybody
    puts "Deadline soon reminded ----------------------"
  end
  
  desc "Cron: Remind & Maintenance"
  task :cron => [:remind, :maintenance, :deadline_soon_reminder]


  desc "Recreate DB and reindex" 
  task :reset => :environment  do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end
end
