set :application, "leihs2test"
set :repository,  "http://code.zhdk.ch/svn/leihs/trunk"
set :db_config, "/home/rails/leihs/leihs2test/database.yml"
set :checkout, :export
set :use_sudo, false

set :rails_env, "production"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/rails/leihs/#{application}"


# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "leihs@webapp.zhdk.ch"
role :web, "leihs@webapp.zhdk.ch"
role :db,  "leihs@webapp.zhdk.ch", :primary => true

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
end

task	:link_attachments do
	run "rm -rf #{release_path}/public/images/attachments"
	run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/images/attachments"
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
  run "sed -i 's/FRONTEND_SPLASH_PAGE = false/FRONTEND_SPLASH_PAGE = true/g' #{release_path}/config/environment.rb"
  run "sed -i 's/INVENTORY_CODE_PREFIX.*/INVENTORY_CODE_PREFIX = [[\"AVZ\", \"AV-Technik\"], [\"ITZS\", \"ITZ\"], [\"ITZV\", \"ITZ\"] ]/' #{release_path}/config/initializers/propose_inventory_code.rb"
  run "sed -i 's/CONTRACT_LENDING_PARTY_STRING.*/CONTRACT_LENDING_PARTY_STRING = \"Zürcher Hochschule der Künste\nAusstellungsstr. 60\n8005 Zürich\"/' #{release_path}/config/environment.rb"
end

task :chmod_tmp do
  run "chmod g-w #{release_path}/tmp"
end

task :configure_sphinx do
 run "cd #{release_path} && RAILS_ENV='production' rake ts:config"
 run "sed -i 's/listen = 127.0.0.1:3312/listen = 127.0.0.1:3342/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/listen = 127.0.0.1:3313/listen = 127.0.0.1:3343/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/listen = 127.0.0.1:3314/listen = 127.0.0.1:3344/' #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/sql_host =.*/sql_host = db.zhdk.ch/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_user =.*/sql_user = leihs2dev/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_pass =.*/sql_pass = 163ruby9/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_db =.*/sql_db = rails_leihs2_dev/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_sock.*//' #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/port: 3312/port: 3342/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/port: 3313/port: 3343/' #{release_path}/config/sphinx.yml"
 run "sed -i 's/port: 3314/port: 3344/' #{release_path}/config/sphinx.yml"

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

	task :restart do
          run "pkill -SIGUSR2 -f -u leihs -- '-e production.*leihs2test'"
	end

  desc "Cleanup older revisions"
  task :after_deploy do
    cleanup
  end 
end

after "deploy:symlink", :link_config
after "deploy:symlink", :link_attachments
after "deploy:symlink", :modify_config
after "deploy:symlink", :chmod_tmp
after "deploy:symlink", :configure_sphinx
before "deploy:restart", :remove_htaccess
before "deploy:restart", :make_tmp
before "deploy", :stop_sphinx
after "deploy", :start_sphinx
