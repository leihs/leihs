task :retrieve_db_config do
  # DB credentials needed by mysqldump etc.
  get(db_config, "/tmp/leihs_db_config.yml")
  dbconf = YAML::load_file("/tmp/leihs_db_config.yml")["production"]
  set :sql_database, dbconf['database']
  set :sql_host, dbconf['host']
  set :sql_username, dbconf['username']
  set :sql_password, dbconf['password']
end
