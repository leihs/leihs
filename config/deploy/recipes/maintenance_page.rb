task :enable_maintenance_page do
  run "touch #{current_release}/public/maintenance.enable"
end

task :disable_maintenance_page do
  run "rm #{current_release}/public/maintenance.enable"
end
