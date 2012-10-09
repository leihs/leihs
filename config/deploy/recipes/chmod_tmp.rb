task :chmod_tmp do
  run "chmod g-w #{release_path}/tmp"
end
