=begin
  pre-setup.rb

  Copyright(c) 2005-2007 Masao Mutoh
  This program is licenced under the same licence as Ruby.

  $Id: pre-setup.rb,v 1.7 2007/11/10 02:51:21 mutoh Exp $
=end

require 'fileutils'

ruby = config("ruby-path")

gettext = "#{File.join(config("siterubyver"), "gettext.rb")}"
gettext_dir = "#{File.join(config("siterubyver"), "gettext")}"
gettext_dir2 = "#{File.join(config("siterubyverarch"), "gettext")}"
FileUtils.rm_f gettext if FileTest.exist?(gettext)
FileUtils.rm_rf gettext_dir if FileTest.exist?(gettext_dir)
FileUtils.rm_rf gettext_dir2 if FileTest.exist?(gettext_dir2)

