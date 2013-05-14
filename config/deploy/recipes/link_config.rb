task :link_config do
  if File.exist?("#{release_path}/config/LDAP.yml")
    run "rm #{release_path}/config/LDAP.yml"
    run "ln -s #{ldap_config} #{release_path}/config/LDAP.yml"
  end
  run "rm -f #{release_path}/config/database.yml"
  run "rm -f #{release_path}/config/application.rb"

  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{app_config} #{release_path}/config/application.rb"

  # So we can check from outside which revision is deployed on that instance
  # Note: Must use a .txt suffix so that Passengers knows to deliver this
  # as text/plain through Apache.
  run "ln -sf  #{release_path}/REVISION #{release_path}/public/REVISION.txt"
end
