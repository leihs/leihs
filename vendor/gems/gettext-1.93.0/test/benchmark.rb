require 'benchmark'
require 'gettext'

include GetText
Benchmark.bm(18){|x|
  x.report("bindtextdomain"){ 50000.times{|i|
    bindtextdomain "test1"
  } }
  x.report("set_locale"){ 50000.times{|i|
    set_locale "ja_JP.UTF-8"
  } }
  set_locale "ja_JP.UTF-8"
  x.report("_() ja found"){ 50000.times{|i|
    _("language")
  } }
  x.report("_() ja not found"){ 50000.times{|i|
    _("language2")
  } }
  set_locale "en"
  x.report("_() en found"){ 50000.times{|i|
    _("language")
  } }
  x.report("_() en not found"){ 50000.times{|i|
    _("language2")
  } }

}

