# encoding: utf-8

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby_version, '2.1.1'

set :application, "leihs-demo-new"

set :scm, :git
set :repository,  "git://github.com/zhdk/leihs.git"
set :deploy_via, :remote_cache

set :db_config, "/home/leihs/#{application}/database.yml"
set :use_sudo, false

set :rails_env, "production"

default_run_options[:shell] = false

set :deploy_to, "/home/leihs/#{application}"
set :secret_token, "/home/leihs/#{application}/secret_token.rb"

role :app, "leihs@rails.zhdk.ch"
role :web, "leihs@rails.zhdk.ch"
role :db,  "leihs@rails.zhdk.ch", :primary => true

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


task :modify_config do
  # On staging/test, we don't want to deliver e-mail
  run "sed -i 's/config.action_mailer.perform_deliveries = true/config.action_mailer.perform_deliveries = false/' #{release_path}/config/environments/production.rb"
end

task :reset_demo_data do
  run "mysql -h #{sql_host} --user=#{sql_username} --password=#{sql_password} #{sql_database} -e 'drop database #{sql_database}'"
  run "mysql -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -e 'create database #{sql_database}'"
  # Super-special shit: We need to reset all data and then tell the leihs 2.9 demo that its database has completely 
  # exploded and that it needs to expire everything it knows about models and availability.
  run "/home/leihs/leihs-demo-new/reseed_demo_data.sh"
end

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

after "link_config", :migrate_database
after "link_config", :modify_config
after "link_config", "precompile_assets"

before "deploy:restart", :make_tmp

after "deploy", "deploy:cleanup"
after "deploy", :reset_demo_data
