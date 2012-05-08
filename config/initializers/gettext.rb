#rails3#
FastGettext.add_text_domain 'leihs', :path => 'locale'#, :type => :po
FastGettext.default_available_locales = ['en-GB', 'de-CH', 'es', 'fr', 'gsw-CH', 'en-US'] #all you want to allow
FastGettext.default_text_domain = 'leihs'

