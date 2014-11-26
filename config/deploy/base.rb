# encoding: utf-8

set :scm, :git
set :repository,  "git://github.com/zhdk/leihs.git"
#set :repository,  "https://github.com/zhdk/leihs.git"
set :rails_env, "production"
set :deploy_via, :remote_cache

set :use_sudo, false

load 'config/deploy/recipes/set_branch'
load 'config/deploy/recipes/retrieve_db_config'
load 'config/deploy/recipes/link_config'
load 'config/deploy/recipes/link_attachments'
load 'config/deploy/recipes/link_db_backups'
load 'config/deploy/recipes/make_tmp'
load 'config/deploy/recipes/chmod_tmp'
load 'config/deploy/recipes/migrate_database'
load 'config/deploy/recipes/bundle_install'
load 'config/deploy/recipes/precompile_assets'
load 'config/deploy/recipes/set_deploy_information'

namespace :deploy do
  task :start do
  # we do absolutely nothing here, as we currently aren't
  # using a spinner script or anything of that sort.
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  # This overwrites the (broken, when using Bundler) deploy:migrate task
    task :migrate do
  end

end

before "deploy", "retrieve_db_config"
before "deploy:cold", "retrieve_db_config"

before "deploy:create_symlink", :link_config
before "deploy:create_symlink", :link_attachments
before "deploy:create_symlink", :link_db_backups
before "deploy:create_symlink", :chmod_tmp

before "migrate_database", :bundle_install

after "link_config", :migrate_database
after "link_config", :modify_config
after "link_config", "precompile_assets"

before "deploy:restart", :set_deploy_information
before "deploy:restart", :make_tmp

after "deploy", "deploy:cleanup"
