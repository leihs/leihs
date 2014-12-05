# encoding: utf-8
unless exists?(:tag)
  p "Automatically setting tag to 'next' because this is staging and no tag was specified."
  set :tag, 'master'
end

load 'config/deploy/base'
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby_version, '2.1.1'

set :application, "leihs-test"

set :db_config, "/home/leihs/#{application}/database.yml"
set :ldap_config, "/home/leihs/#{application}/LDAP.yml"
set :newrelic_config, "/home/leihs/#{application}/newrelic.yml"
set :secret_token, "/home/leihs/#{application}/secret_token.rb"

set :use_sudo, false

set :deploy_to, "/home/leihs/#{application}"

role :app, "leihs@rails.zhdk.ch"
role :web, "leihs@rails.zhdk.ch"
role :db,  "leihs@rails.zhdk.ch", :primary => true


task :modify_config do
  # On staging/test, we don't want to deliver e-mail
  run "sed -i 's/config.action_mailer.perform_deliveries = true/config.action_mailer.perform_deliveries = false/' #{release_path}/config/environments/production.rb"
end

before "deploy:restart", :set_deploy_information
