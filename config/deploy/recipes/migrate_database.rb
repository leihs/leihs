task :migrate_database do
  # Produce a string like 2010-07-15T09-16-35+02-00
  date_string = DateTime.now.to_s.gsub(":","-")
  dump_dir = "#{deploy_to}/#{shared_dir}/db_backups"
  run "mkdir -p #{dump_dir}"
  dump_path =  "#{dump_dir}/#{sql_database}-#{date_string}.sql"
  # If mysqldump fails for any reason, Capistrano will stop here
  # because run catches the exit code of mysqldump
  run "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"
  run "bzip2 #{dump_path}"
  run "cd #{release_path} && rbenv shell #{rbenv_ruby_version} && RAILS_ENV='production' bundle exec rake db:migrate"
end
