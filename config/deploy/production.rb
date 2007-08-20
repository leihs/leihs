set :application, "leihstest"
set :repository,  "http://code.zhdk.ch/svn/leihs/trunk"
set :use_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# These settings are for testing on your local machine only.
set :deploy_to, "/home/rails/leihs/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "webapp.zhdk.ch"
role :web, "webapp.zhdk.ch"
role :db,  "db.zhdk.ch", :primary => true

task :restart_web_server, :roles => :web do
   sudo "/etc/init.d/apache2 reload" 
end

after "deploy:start", :restart_web_server
