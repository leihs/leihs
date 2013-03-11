# encoding: utf-8
set :application, "leihs2"

set :scm, :git
set :repository,  "git://github.com/zhdk/leihs.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :db_config, "/home/rails/leihs/leihs2/database.yml"
set :ldap_config, "/home/rails/leihs/leihs2/LDAP.yml"
set :use_sudo, false

set :rails_env, "production"

default_run_options[:shell] = false

# DB credentials needed by Sphinx, mysqldump etc.
set :sql_database, "rails_leihs2_prod"
set :sql_host, "db.zhdk.ch"
set :sql_username, "leihs2prod"
set :sql_password, "cueGbx5F3"


# User Variables and Settings
set :contract_lending_party_string, "Zürcher Hochschule der Künste\nAusstellungsstr. 60\n8005 Zürich"
set :default_email, "ausleihe.benachrichtigung\@zhdk.ch"
set :email_server, "smtp.zhdk.ch"
set :email_port, 25
set :email_domain, "ausleihe.zhdk.ch"
set :email_charset, "utf-8"
set :email_content_type, "text/html"
set :email_signature, "Das PZ-leihs Team"
set :deliver_order_notifications, false # This is false by default. TODO: Actually set them to true if this is true.
set :perform_deliveries, true
set :local_currency, "CHF"
# Escape double-quotes using triple-backslashes in this string: \\\"
set :contract_terms, 'Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die \\\"Richtlinie zur Ausleihe von Sachen\\\" der ZHdK und etwaige abteilungsspezifische Ausleih-Richtlinien.'


set :deploy_to, "/home/rails/leihs/#{application}"

role :app, "leihs@webapp.zhdk.ch"
role :web, "leihs@webapp.zhdk.ch"
role :db,  "leihs@webapp.zhdk.ch", :primary => true

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  on_rollback { run "rm #{release_path}/config/LDAP.yml" }
  run "rm #{release_path}/config/database.yml"
  run "rm #{release_path}/config/LDAP.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{ldap_config} #{release_path}/config/LDAP.yml"
end

task :link_attachments do
	run "rm -rf #{release_path}/public/images/attachments"
	run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/images/attachments"

  run "rm -rf #{release_path}/public/attachments"
  run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/attachments"
end

task  :link_db_backups do
  run "rm -rf #{release_path}/db/backups"
  run "ln -s #{deploy_to}/#{shared_dir}/db_backups #{release_path}/db/backups"
end

task :link_sphinx do
  run "rm -rf #{release_path}/db/sphinx"
  run "ln -s #{deploy_to}/#{shared_dir}/sphinx #{release_path}/db/sphinx"
end

task :remove_htaccess do
	# Kill the .htaccess file as we are using mongrel, so this file
	# will only confuse the web server if parsed.

	run "rm #{release_path}/public/.htaccess"
end

task :make_tmp do
	run "mkdir -p #{release_path}/tmp/sessions #{release_path}/tmp/cache"
end

task :modify_config do
  set :configfile, "#{release_path}/config/environment.rb"
  run "sed -i 's|CONTRACT_LENDING_PARTY_STRING.*|CONTRACT_LENDING_PARTY_STRING = \"#{contract_lending_party_string}\"|' #{configfile}"
  run "sed -i 's|DEFAULT_EMAIL.*|DEFAULT_EMAIL = \"#{default_email}\"|' #{configfile}"
  run "sed -i 's|:address.*|:address => \"#{email_server}\",|' #{configfile}"
  run "sed -i 's|:port.*|:port => #{email_port},|' #{configfile}"
  run "sed -i 's|:domain.*|:domain => \"#{email_domain}\"|' #{configfile}"
  run "sed -i 's|ActionMailer::Base.default_charset.*|ActionMailer::Base.default_charset = \"#{email_charset}\"\nActionMailer::Base.default_content_type = \"#{email_content_type}\"|' #{configfile}"
  run "sed -i 's|EMAIL_SIGNATURE.*|EMAIL_SIGNATURE = \"#{email_signature}\"|' #{configfile}"
  run "sed -i 's|:encryption|#:encryption|' #{release_path}/app/controllers/authenticator/ldap_authentication_controller.rb"
  run "sed -i 's|CONTRACT_TERMS.*|CONTRACT_TERMS = \"#{contract_terms}\"|' #{configfile}"
  run "sed -i 's|LOCAL_CURRENCY_STRING.*|LOCAL_CURRENCY_STRING = \"#{local_currency}\"|' #{configfile}"
  run "echo 'config.action_mailer.perform_deliveries = false' >> #{release_path}/config/environments/production.rb" if perform_deliveries == false
end

task :chmod_tmp do
  run "chmod g-w #{release_path}/tmp"
end

task :configure_sphinx do
 run "cd #{release_path} && RAILS_ENV='production' rake ts:config"
 run "sed -i 's/listen = 127.0.0.1:3312/listen = 127.0.0.1:3362/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/listen = 127.0.0.1:3313/listen = 127.0.0.1:3363/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/listen = 127.0.0.1:3314/listen = 127.0.0.1:3364/' #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/listen = 127.0.0.1:3342/listen = 127.0.0.1:3362/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/listen = 127.0.0.1:3343/listen = 127.0.0.1:3363/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/listen = 127.0.0.1:3344/listen = 127.0.0.1:3364/' #{release_path}/config/production.sphinx.conf"


 run "sed -i 's/sql_host =.*/sql_host = #{sql_host}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_user =.*/sql_user = #{sql_username}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_pass =.*/sql_pass = #{sql_password}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_db =.*/sql_db = #{sql_database}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_sock.*//' #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/port: 3312/port: 3362/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/port: 3313/port: 3363/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/port: 3314/port: 3364/' #{release_path}/config/sphinx.yml"

 run "sed -i 's/port: 3342/port: 3362/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/port: 3343/port: 3363/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/port: 3344/port: 3364/' #{release_path}/config/sphinx.yml"

 run "sed -i 's/listen: 127.0.0.1:3312/listen: 127.0.0.1:3362/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/listen: 127.0.0.1:3313/listen: 127.0.0.1:3363/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/listen: 127.0.0.1:3314/listen: 127.0.0.1:3364/' #{release_path}/config/sphinx.yml"

 run "sed -i 's/listen: 127.0.0.1:3342/listen: 127.0.0.1:3362/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/listen: 127.0.0.1:3343/listen: 127.0.0.1:3363/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/listen: 127.0.0.1:3344/listen: 127.0.0.1:3364/' #{release_path}/config/sphinx.yml"


end


task :migrate_database do
  # Produce a string like 2010-07-15T09-16-35+02-00
  date_string = DateTime.now.to_s.gsub(":","-")
  dump_dir = "#{deploy_to}/#{shared_dir}/db_backups"
  dump_path =  "#{dump_dir}/#{sql_database}-#{date_string}.sql"
  # If mysqldump fails for any reason, Capistrano will stop here
  # because run catches the exit code of mysqldump
  run "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"
  run "bzip2 #{dump_path}"

  # Migration here 
  # deploy.migrate should work, but is buggy and is run in the _previous_ release's
  # directory, thus never runs anything? Strange.
  #deploy.migrate
  run "cd #{release_path} && RAILS_ENV='production' rake db:migrate"

end

task :install_gems do
  run "cd #{release_path} && bundle install --deployment --without cucumber profiling"
  run "sed -i 's/BUNDLE_DISABLE_SHARED_GEMS: \"1\"/BUNDLE_DISABLE_SHARED_GEMS: \"0\"/' #{release_path}/.bundle/config"
end

task :stop_sphinx do
  run "cd #{previous_release} && RAILS_ENV='production' rake ts:stop"
end

task :start_sphinx do
  run "cd #{release_path} && RAILS_ENV='production' rake ts:reindex"
  run "cd #{release_path} && RAILS_ENV='production' rake ts:start"
end


namespace :deploy do
	task :start do
          run "passenger start -p 3003 -e production -d"
	end

   task :restart, :roles => :app, :except => { :no_release => true } do
     # We cannot use Passenger on the server because this app runs with a legacy Ruby 1.8.7 and legacy Rails.
     # That's why we have to restart using a proxied standalone Passenger server.
     #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
     run "passenger stop -p 3003 && passenger start -p 3003 -e production -d"
   end

end



after "deploy:symlink", :link_config
after "deploy:symlink", :link_attachments
after "deploy:symlink", :link_db_backups
after "deploy:symlink", :modify_config
after "deploy:symlink", :chmod_tmp
before "migrate_database", :install_gems
after "deploy:symlink", :migrate_database
after "migrate_database", :configure_sphinx
before "deploy:restart", :remove_htaccess
before "deploy:restart", :make_tmp
before "deploy", :stop_sphinx
before "start_sphinx", :link_sphinx
after "deploy", :start_sphinx
after "deploy", "deploy:cleanup"
