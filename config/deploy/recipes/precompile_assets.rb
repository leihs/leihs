task :precompile_assets do
  run "cd #{release_path} && rbenv shell #{rbenv_ruby_version} && RAILS_ENV=production bundle exec rake assets:precompile"

  # NOTE after upgrading to Rails 4, the assets precompilation doesn't keep the original filename without fingerprint anymore
  # the timeline library has hardcoded filename which are loaded dynamically
  run "cd #{release_path} && rbenv shell #{rbenv_ruby_version} && cp -r vendor/assets/javascripts/simile_timeline/timeline_js public/assets/simile_timeline/"
end
