# encoding: utf-8
load 'config/deploy/base'

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby_version, '2.1.1'

set :application, "leihs-demo-new"

set :db_config, "/home/leihs/#{application}/database.yml"
set :ldap_config, false
set :use_sudo, false

set :deploy_to, "/home/leihs/#{application}"
set :secret_token, "/home/leihs/#{application}/secret_token.rb"

role :app, "leihs@rails.zhdk.ch"
role :web, "leihs@rails.zhdk.ch"
role :db,  "leihs@rails.zhdk.ch", :primary => true

task :modify_config do
  # On staging/test, we don't want to deliver e-mail
  run "sed -i 's/config.action_mailer.perform_deliveries = true/config.action_mailer.perform_deliveries = false/' #{release_path}/config/environments/production.rb"
end

task :reset_demo_data do
  #run "mysql -h #{sql_host} --user=#{sql_username} --password=#{sql_password} #{sql_database} -e 'drop database #{sql_database}'"
  #run "mysql -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -e 'create database #{sql_database}'"
  run "/home/leihs/leihs-demo-new/reseed_demo_data.sh"
end

after "deploy", :reset_demo_data
