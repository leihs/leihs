ActionView::Base.send :include, Greybox

# install files if missing. I prefer this to install.rb because it allows it to be checked out vs installed without issue.
PUBLIC = File.join([File.dirname(__FILE__), %w(.. .. .. public)].flatten)
unless File.exists? File.join(PUBLIC, 'greybox')
  puts "** Installing greybox files in public folder"
  GREYBOX_ASSETS = File.join(File.dirname(__FILE__), 'assets', 'greybox')
  FileUtils.cp_r Dir[GREYBOX_ASSETS], PUBLIC
end