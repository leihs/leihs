set :application, "leihs"
set :repository,  "http://code.zhdk.ch/svn/leihs/trunk"
set :use_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# These settings are for testing on your local machine only.
set :deploy_to, "/var/www/rails/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "localhost"
role :web, "localhost"
role :db,  "localhost", :primary => true
