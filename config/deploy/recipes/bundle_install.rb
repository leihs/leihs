# The built-in capistrano/bundler integration seems broken: It does not cd to release_path but instead
# to the previous release, which has the wrong Gemfile. This fixes that, but of course means we cannot use 
# the built-in bundler support.
task :bundle_install do
  run "cd #{release_path} && bundle install --path '#{deploy_to}/#{shared_dir}/bundle' --deployment --without development test"
end
