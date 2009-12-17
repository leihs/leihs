
# NOTE require must be inside the tasks

#require 'gettext/utils'

# Tell ruby-gettext's ErbParser to parse .erb files as well
# See also http://zargony.com/2007/07/29/using-ruby-gettext-with-edge-rails
#GetText::ErbParser.init(:extnames => ['.rhtml', '.erb'])


desc "Create mo-files for L10n" 
task :makemo => :environment do
  require 'gettext/utils'
  GetText::ErbParser.init(:extnames => ['.rhtml', '.erb'])

 GetText.create_mofiles(true, "po", "locale")
end


desc "Update pot/po files to match new version." 
task :updatepo => :environment do
  require 'gettext/utils'
  GetText::ErbParser.init(:extnames => ['.rhtml', '.erb'])

 MY_APP_TEXT_DOMAIN = "leihs" 
 MY_APP_VERSION     = "leihs 2.0.0" 
 GetText.update_pofiles(MY_APP_TEXT_DOMAIN,
                        Dir.glob("{app,lib}/**/*.{rb,rhtml,erb,rfpdf}"),
                        MY_APP_VERSION)
end
