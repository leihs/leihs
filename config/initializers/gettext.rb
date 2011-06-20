#rails3#
FastGettext.add_text_domain 'leihs', :path => 'locale'#, :type => :po
FastGettext.default_available_locales = ['en_US','de_CH', 'es', 'fr', 'gsw_CH'] #all you want to allow
FastGettext.default_text_domain = 'leihs'

