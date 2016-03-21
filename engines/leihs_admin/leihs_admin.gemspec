$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'leihs_admin/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'leihs_admin'
  s.version     = LeihsAdmin::VERSION
  s.authors     = ['Franco Sellitto']
  s.email       = ['franco.sellitto@zhdk.ch']
  s.homepage    = 'https://github.com/zhdk/leihs'
  s.summary     = 'leihs admin'
  s.description = 'leihs admin'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.2.6'
  s.add_dependency 'rails-assets-jquery', '~>1.5'
  s.add_dependency 'rails-assets-jquery-ujs', '~>1.0'
  s.add_dependency 'rails-assets-bootstrap', '~>3.3'
  # s.add_dependency 'font-awesome-sass', '~>4.4'
  s.add_dependency 'rails-assets-select2', '~>4.0'
end
