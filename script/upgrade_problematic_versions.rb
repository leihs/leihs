

def upgrade_to(version)
  puts "Switching to leihs #{version}"
  system "git reset --hard #{version}"
  system "bundle install --deployment --without development test cucumber" 
  system "RAILS_ENV=production bundle exec rake db:migrate"
end

#versions = %w(3.0.0-rc.1.4 3.0.0-rc.1.5 3.0.1 3.0.2 3.0.3 3.0.4 3.1.0 3.2.0 3.2.1 3.3.0 3.3.1 3.3.2 3.4.0 3.5.0 3.5.1 3.6.0 3.6.1 3.7.0 3.8.0 3.9.0 3.10.0 3.11.0 3.12.0 3.13.0 3.13.1 3.14.0 3.15.0 3.16.0 3.16.1 3.17.0 3.18.0 3.18.1 3.19.0 3.19.1 3.20.0 3.21.0 3.22.0 3.23.0 3.24.0 3.24.1 3.25.1 3.25.2 3.25.3 3.25.4 3.25.5 3.26.0 3.26.1 3.26.2 3.27.0 3.28.0 3.28.1 3.29.0 3.29.1 3.30.0 3.30.1 3.31.0 3.32.0 3.32.1 3.32.2)


versions = %w(3.0.0-rc.1.4 3.0.0-rc.1.5 3.0.1 3.5.0 3.14.0 3.23.0 3.24.0 3.24.1 3.25.1 3.25.2 3.25.3 3.25.4 3.25.5 3.26.0 3.26.2 3.27.0 3.28.0 3.28.1 3.29.0 3.29.1 3.30.0 3.30.1 3.31.0 3.32.0 3.32.1 3.32.2)

system "git fetch"
system "gem update --system 1.8.24"

versions.each do |version|
  exit_status = upgrade_to(version)
  if exit_status == true
    puts "Upgraded to #{version}"
  elsif exit_status == nil or exit_status == false
    puts "Upgrade to #{version} failed"
    Kernel.exit 
  end
end

system "gem update --system"
