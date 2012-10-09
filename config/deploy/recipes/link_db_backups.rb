task :link_db_backups do
  run "rm -rf #{release_path}/db/backups"
  run "mkdir -p #{release_path}/db/backups"
  run "ln -s #{deploy_to}/#{shared_dir}/db_backups #{release_path}/db/backups"
end
