require 'hoe'
require './lib/png.rb'

Hoe.new 'png', PNG::VERSION do |s|
  s.rubyforge_name = 'seattlerb'
  s.author = ['Ryan Davis', 'Eric Hodel']
  s.email = 'support@zenspider.com'

  s.summary = 'An almost-pure-ruby PNG library'
  s.description = s.paragraphs_of('README.txt', 3..7).join("\n\n")

  s.changes = s.paragraphs_of('History.txt', 0..1).join("\n\n")

  s.extra_deps << ['RubyInline', '>= 3.5.0']
end

# vim: syntax=Ruby
