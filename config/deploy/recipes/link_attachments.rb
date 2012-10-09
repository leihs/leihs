task :link_attachments do
  #run "rm -rf #{release_path}/public/images/attachments"
  run "mkdir -p #{release_path}/public/images"
  run "ln -sf #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/images/attachments"

  #run "rm -rf #{release_path}/public/attachments"
  run "ln -sf #{deploy_to}/#{shared_dir}/attachments #{release_path}/public/attachments"
end
