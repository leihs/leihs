=begin
  utils.rb - Utility functions

  Copyright (C) 2005,2006 Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

require 'rbconfig'
if /mingw|mswin|mswin32/ =~ RUBY_PLATFORM
  ENV['PATH'] = %w(bin lib).collect{|dir|
    "#{Config::CONFIG["prefix"]}\\lib\\GTK\\#{dir};"
  }.join('') + ENV['PATH']
end

require 'gettext/rgettext'
require 'gettext/rmsgfmt'
require 'fileutils'

module GetText
  bindtextdomain "rgettext"

  BOM_UTF8 = [0xef, 0xbb, 0xbf].pack("c3")

  module_function

  # Currently, GNU msgmerge doesn't accept BOM. 
  # This mesthod remove the UTF-8 BOM from the po-file.
  def remove_bom(path)  #:nodoc:
    bom = IO.read(path, 3)
    if bom == BOM_UTF8
      data = IO.read(path)
      File.open(path, "w") do |out|
        out.write(data[3..-1])
      end
    end
  end

  # Merges two Uniforum style .po files together. 
  #
  # *Note* This function requires "msgmerge" tool included in GNU GetText. So you need to install GNU GetText. 
  #
  # The def.po file is an existing PO file with translations which will be taken 
  # over to the newly created file as long as they still match; comments will be preserved,
  # but extracted comments and file positions will be discarded. 
  #
  # The ref.pot file is the last created PO file with up-to-date source references but
  # old translations, or a PO Template file (generally created by rgettext);
  # any translations or comments in the file will be discarded, however dot
  # comments and file positions will be preserved.  Where an exact match
  # cannot be found, fuzzy matching is used to produce better results.
  #
  # Usually you don't need to call this function directly. Use GetText.update_pofiles instead.
  #
  # * defpo: a po-file. translations referring to old sources
  # * refpo: a po-file. references to new sources
  # * app_version: the application information which appears "Project-Id-Version: #{app_version}" in the pot/po-files.
  # * Returns: self 
  def msgmerge(defpo, refpo, app_version) 
    $stderr.print defpo + " "
    cmd = ENV["MSGMERGE_PATH"] || "msgmerge"

    cont = ""
    if FileTest.exist? defpo
      `#{cmd} --help`
      unless $? && $?.success?
        raise _("`%{cmd}' may not be found. \nInstall GNU Gettext then set PATH or MSGMERGE_PATH correctly.") % {:cmd => cmd}
      end
      remove_bom(defpo)
      cont = `#{cmd} #{defpo} #{refpo}`
    else
      File.open(refpo) do |io| 
	cont = io.read
      end
    end
    if cont.empty?
      failed_filename = refpo + "~"
      FileUtils.cp(refpo, failed_filename)
      $stderr.puts _("Failed to merge with %{defpo}") % {:defpo => defpo}
      $stderr.puts _("New .pot was copied to %{failed_filename}") %{:failed_filename => failed_filename}
      raise _("Check these po/pot-files. It may have syntax errors or something wrong.")
    else
      cont.sub!(/(Project-Id-Version\:).*$/, "\\1 #{app_version}\\n\"")
      File.open(defpo, "w") do |out|
        out.write(cont)
      end
    end
    self
  end

  def msgmerge_all(textdomain, app_version, po_root = "po", refpot = "tmp.pot") # :nodoc:
    FileUtils.mkdir_p(po_root) unless FileTest.exist? po_root
    msgmerge("#{po_root}/#{textdomain}.pot", refpot, app_version)
    
    Dir.glob("#{po_root}/*/#{textdomain}.po"){ |f|
      lang = /#{po_root}\/(.*)\//.match(f).to_a[1]
      msgmerge("#{po_root}/#{lang}/#{textdomain}.po", refpot, app_version)
    }
  end

  # Creates mo-files using #{po_root}/#{lang}/*.po an put them to 
  # #{targetdir}/#{targetpath_rule}/. 
  #
  # This is a convenience function of GetText.rmsgfmt for plural target files. 
  # * verbose: true if verbose mode, otherwise false
  # * po_root: the root directory of po-files.
  # * targetdir: the target root directory where the mo-files are stored.
  # * targetpath_rule: the target directory for each mo-files. "%s" becomes "#{lang}" under po_root.
  def create_mofiles(verbose = false, 
		     podir = "./po", targetdir = "./data/locale", 
		     targetpath_rule = "%s/LC_MESSAGES") 

    modir = File.join(targetdir, targetpath_rule)
    Dir.glob(File.join(podir, "*/*.po")) do |file|
      lang, basename = /\/([^\/]+?)\/(.*)\.po/.match(file[podir.size..-1]).to_a[1,2]
      outdir = modir % lang
      FileUtils.mkdir_p(outdir) unless File.directory?(outdir)
      $stderr.print %Q[#{file} -> #{File.join(outdir, "#{basename}.mo")} ... ] if verbose
      begin
        rmsgfmt(file, File.join(outdir, "#{basename}.mo"))
      rescue Exception => e
        $stderr.puts "Error." if verbose
        raise e
      end
      $stderr.puts "Done." if verbose
    end
  end


  # At first, this creates the #{po_root}/#{domainname}.pot file using GetText.rgettext.
  # Since 2nd time, this updates(merges) the #{po_root}/#{domainname}.pot and all of the 
  # #{po_root}/#{lang}/#{domainname}.po files under "po_root" using "msgmerge". 
  #
  # *Note* "msgmerge" tool is included in GNU GetText. So you need to install GNU GetText. 
  #
  # See <HOWTO maintain po/mo files(http://www.yotabanana.com/hiki/ruby-gettext-howto-manage.html)> for more detals.
  # * domainname: the textdomain name.
  # * targetfiles: An Array of target files or nil (See GetText.rgettext for more details).
  # * app_version: the application information which appears "Project-Id-Version: #{app_version}" in the pot/po-files.
  # * po_root: the root directory of po-files.
  # * refpot: set the temporary file name. You shouldn't use this(It will be removed).
  #
  #  (e.g.) GetText.update_pofiles("myapp", Dir.glob("lib/*.rb"), "myapp 1.0.0")
  def update_pofiles(textdomain, files, app_version, po_root = "po", refpot = "tmp.pot")
    rgettext(files, refpot)
    msgmerge_all(textdomain, app_version, po_root, refpot)
    File.delete(refpot)
  end
end

if __FILE__ == $0
  GetText.update_pofiles("foo", ARGV, "foo 1.1.0")
end
