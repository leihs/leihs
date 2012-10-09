task :precompile_assets do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake assets:precompile"
end
