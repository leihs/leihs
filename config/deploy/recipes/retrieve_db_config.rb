task :retrieve_db_config do
  # DB credentials needed by mysqldump etc.
  filename = "leihs_db_config_#{rand(1000..50000)}.yml"
  tmp_dir = "/tmp"
  get(db_config, "#{tmp_dir}/#{filename}")
  dbconf = YAML::load_file("#{tmp_dir}/#{filename}")["production"]
  set :sql_database, dbconf['database']
  set :sql_host, dbconf['host']
  set :sql_username, dbconf['username']
  set :sql_password, dbconf['password']
end
