task :link_config do
  if exists?(:ldap_config)
    run "if [[ -f #{ldap_config} ]]; then ln -sf #{ldap_config} #{release_path}/config/LDAP.yml; fi"
  end

  if exists?(:secret_token)
    run "if [[ -f #{ldap_config} ]]; then ln -sf #{secret_token} #{release_path}/config/initializers/secret_token.rb; fi"
  end

  run "rm -f #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"

  # So we can check from outside which revision is deployed on that instance
  # Note: Must use a .txt suffix so that Passengers knows to deliver this
  # as text/plain through Apache.
  run "ln -sf  #{release_path}/REVISION #{release_path}/public/REVISION.txt"
end
