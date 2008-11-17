ActionView::Base.send :include, Greybox

# install files if missing. I prefer this to install.rb because it allows it to be checked out vs installed without issue.
# adapted by sellittf

#old#
#public_path = File.join(File.dirname(__FILE__), %w(.. .. .. public))
#unless File.exists? File.join(public_path, 'greybox')
#  puts "** Installing greybox files in public folder"
#  greybox_assets = File.join(File.dirname(__FILE__), %w(assets greybox ** *))
#  FileUtils.cp_r Dir[greybox_assets], public_path
#end

public_path = File.join(File.dirname(__FILE__), %w(.. .. .. public))
greybox_path = File.join(public_path, %w(javascripts greybox))
unless File.exists? greybox_path
  puts "** Installing greybox files in public folder"
  greybox_assets = File.join(File.dirname(__FILE__), %w(assets greybox ** *))
  FileUtils.mkdir_p greybox_path
  FileUtils.cp_r Dir[greybox_assets], greybox_path
end
