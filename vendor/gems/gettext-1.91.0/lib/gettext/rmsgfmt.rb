=begin
  rmsgfmt.rb - Generate a .mo

  Copyright (C) 2003-2006 Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

require 'optparse'
require 'fileutils'
require 'gettext'
require 'gettext/poparser'
require 'rbconfig'

module GetText
  GetText.bindtextdomain("rgettext")

  module RMsgfmt  #:nodoc:
    extend GetText 

    VERSION = GetText::VERSION 
    DATE = %w($Date: 2006/06/11 15:36:20 $)[1] # :nodoc:
    
    module_function
    def run(targetfile = nil, output_path = nil) # :nodoc:
      unless targetfile
	targetfile, output_path = check_options
      end
      unless targetfile
	raise ArgumentError, _("no input files")
      end
      unless output_path
	output_path = "messages.mo"
      end

      parser = PoParser.new
      data = MOFile.new
      parser.parse(File.open(targetfile).read, data)
      data.save_to_file(output_path)
    end

    def check_options # :nodoc:
      output = nil

      opts = OptionParser.new
      opts.banner = _("Usage: %s input.po [-o output.mo]" % $0)
      opts.separator("")
      opts.separator(_("Generate binary message catalog from textual translation description."))
      opts.separator("")
      opts.separator(_("Specific options:"))

      opts.on("-o", "--output=FILE", _("write output to specified file")) do |out|
	output = out
      end

      opts.on_tail("--version", _("display version information and exit")) do
	puts "#{$0} #{VERSION} (#{DATE})"
	puts "#{File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"])} #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
	exit
      end
      opts.parse!(ARGV)

      if ARGV.size == 0
	puts opts.help
	exit 1
      end

      [ARGV[0], output]
    end
  end

  module_function
  # Creates a mo-file from a targetfile(po-file), then output the result to out. 
  # If no parameter is set, it behaves same as command line tools(rmsgfmt).
  # * targetfile: An Array of po-files or nil.
  # * output_path: output path.
  # * Returns: the MOFile object.
  def rmsgfmt(targetfile = nil, output_path = nil)
    RMsgfmt.run(targetfile, output_path)
  end

  # Move to gettext/utils.rb. This will be removed in the feature. 
  # This remains for backward compatibility. Use gettext/utils.rb instead.
  def create_mofiles(verbose = false, 
		     podir = "./po", targetdir = "./data/locale", 
		     targetpath_rule = "%s/LC_MESSAGES") #:nodoc:
    $stderr.puts "This function will be moved to utils.rb. So requires 'utils' first, please."
    modir = File.join(targetdir, targetpath_rule)
    Dir.glob(File.join(podir, "*/*.po")) do |file|
      lang, basename = /\/([^\/]+?)\/(.*)\.po/.match(file[podir.size..-1]).to_a[1,2]
      outdir = modir % lang
      FileUtils.mkdir_p(outdir) unless File.directory?(outdir)
      rmsgfmt(file, File.join(outdir, "#{basename}.mo"))
      if verbose
	$stderr.puts %Q[#{file} -> #{File.join(outdir, "#{basename}.mo")}]
      end
    end
    self
  end
end

if $0 == __FILE__ then
  GetText.rmsgfmt
end
