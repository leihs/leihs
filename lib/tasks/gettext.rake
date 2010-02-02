desc "Create mo-files for L10n"
task :makemo do
  require 'gettext_rails/tools'
  ENV['LANG'] = 'en_US'
  ENV['LANGUAGE'] = 'en_US'
  GetText.create_mofiles
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext_rails/tools'
  GetText.update_pofiles("leihs", Dir.glob("{app,lib}/**/*.{rb,erb,prawn}"),
                         "leihs 2")
end

