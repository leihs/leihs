task :make_tmp do
	run "mkdir -p #{release_path}/tmp/sessions #{release_path}/tmp/cache"
end
