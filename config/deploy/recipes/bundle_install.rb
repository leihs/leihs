# The built-in capistrano/bundler integration does not work with rbenv,
# and the semi-official rbenv integration for Capistrano is broken
# for Capistrano < 3.0, so we have to write our own.
task :bundle_install do
  run "cd #{release_path} && rbenv shell #{rbenv_ruby_version} && bundle install --path '#{deploy_to}/#{shared_dir}/bundle' --deployment --without development test"
end
