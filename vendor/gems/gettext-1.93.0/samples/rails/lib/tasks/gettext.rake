#
# Added for Ruby-GetText-Package
#

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext/utils'
  GetText.update_pofiles("blog", Dir.glob("{app,lib}/**/*.{rb,erb}"),
			 "blog 2.0.0")
end
