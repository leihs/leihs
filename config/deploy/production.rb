set :application, "leihs2"

set :scm, :git
set :repository,  "git://github.com/psy-q/leihs.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :db_config, "/home/rails/leihs/leihs2/database.yml"
set :use_sudo, false

set :rails_env, "production"

default_run_options[:shell] = false

# DB credentials needed by Sphinx, mysqldump etc.
set :sql_database, "rails_leihs2_prod"
set :sql_host, "db.zhdk.ch"
set :sql_username, "leihs2prod"
set :sql_password, "cueGbx5F3"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/rails/leihs/#{application}"

role :app, "leihs@webapp.zhdk.ch"
role :web, "leihs@webapp.zhdk.ch"
role :db,  "leihs@webapp.zhdk.ch", :primary => true

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
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

task :remove_htaccess do
	# Kill the .htaccess file as we are using mongrel, so this file
	# will only confuse the web server if parsed.

	run "rm #{release_path}/public/.htaccess"
end

task :make_tmp do
	run "mkdir -p #{release_path}/tmp/sessions #{release_path}/tmp/cache"
end

task :modify_config do
  run "sed -i 's/INVENTORY_CODE_PREFIX.*/INVENTORY_CODE_PREFIX = [[\"AVZ\", \"AV-Technik\"], [\"ITZS\", \"ITZ\"], [\"ITZV\", \"ITZ\"] ]/' #{release_path}/config/initializers/propose_inventory_code.rb"
  run "sed -i 's/CONTRACT_LENDING_PARTY_STRING.*/CONTRACT_LENDING_PARTY_STRING = \"Zürcher Hochschule der Künste\nAusstellungsstr. 60\n8005 Zürich\"/' #{release_path}/config/environment.rb"
  run "sed -i 's/DEFAULT_EMAIL = \'sender@example.com\'/DEFAULT_EMAIL = \"ausleihe.benachrichtigung@zhdk.ch\"/' #{release_path}/config/environment.rb"
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


task :stop_sphinx do
  run "cd #{previous_release} && RAILS_ENV='production' rake ts:stop"
end

task :start_sphinx do
  run "cd #{release_path} && RAILS_ENV='production' rake ts:reindex"
  run "cd #{release_path} && RAILS_ENV='production' rake ts:start"
end


namespace :deploy do
	task :start do
	# we do absolutely nothing here, as we currently aren't
	# using a spinner script or anything of that sort.
	end

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

end




after "deploy:symlink", :link_db_backups
after "deploy:symlink", :link_config
after "deploy:symlink", :link_attachments
after "deploy:symlink", :modify_config
after "deploy:symlink", :chmod_tmp
after "deploy:symlink", :migrate_database
after "migrate_database", :configure_sphinx
before "deploy:restart", :remove_htaccess
before "deploy:restart", :make_tmp
before "deploy", :stop_sphinx
after "deploy", :start_sphinx
after "deploy", "deploy:cleanup"
