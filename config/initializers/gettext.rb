# -*- coding: utf-8 -*-
#rails3#
#FastGettext.add_text_domain 'leihs', :path => 'locale'#, :type => :po

# We can use .po files directly. It's just as fast as using .mo files and saves us the gettext:pack step
FastGettext.add_text_domain 'leihs', :path => 'locale', :type => :po
# DANGER, WARNING: Use underscores when separating language from region (e.g. "en_US"). Not using underscores will
# trigger Ragnarök and the world of mortals will cease its pitiful existence.
FastGettext.default_available_locales = ['en_GB', 'de_CH', 'es', 'fr', 'gsw_CH', 'en_US'] #all you want to allow
FastGettext.default_text_domain = 'leihs'

