#! /usr/bin/env ruby
=begin
  rgettext.rb - Generate a .pot file.

  Copyright (C) 2003-2006  Masao Mutoh
  Copyright (C) 2001,2002  Yasushi Shoji, Masao Mutoh
 
      Yasushi Shoji   <yashi at atmark-techno.com>
      Masao Mutoh     <mutoh at highway.ne.jp>
 
  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

require 'optparse'
require 'gettext'
require 'rbconfig'

module GetText

  module RGetText #:nodoc:
    extend GetText

    bindtextdomain("rgettext")

    # constant values
    VERSION = GetText::VERSION
    DATE = %w($Date: 2008/08/06 17:35:52 $)[1]
    MAX_LINE_LEN = 70

    @ex_parsers = []
    [
      ["glade.rb", "GladeParser"],
      ["erb.rb", "ErbParser"],
      ["active_record.rb", "ActiveRecordParser"],
#      ["ripper.rb", "RipperParser"],
      ["ruby.rb", "RubyParser"] # Default parser.
    ].each do |f, klass|
      begin
	require "gettext/parser/#{f}"
	@ex_parsers << GetText.const_get(klass)
      rescue
	$stderr.puts _("'%{klass}' is ignored.") % {:klass => klass}
	$stderr.puts $! if $DEBUG
      end
    end

    module_function

    # Add an option parser
    # the option parser module requires to have target?(file) and parser(file, ary) method.
    # 
    #  require 'gettext/rgettext'
    #  module FooParser
    #    module_function
    #    def target?(file)
    #      File.extname(file) == '.foo'  # *.foo file only.
    #    end
    #    def parse(file, ary)
    #      :
    #      return ary # [["msgid1", "foo.rb:200"], ["msgid2", "bar.rb:300", "baz.rb:400"], ...]
    #    end
    #  end
    #  
    #  GetText::RGetText.add_parser(FooParser)
    def add_parser(klass)
      @ex_parsers.insert(0, klass)
    end

    def generate_pot_header # :nodoc:
      time = Time.now.strftime("%Y-%m-%d %H:%M")
      off = Time.now.utc_offset
      sign = off <= 0 ? '-' : '+'
      time += sprintf('%s%02d%02d', sign, *(off.abs / 60).divmod(60))

      %Q[# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"POT-Creation-Date: #{time}\\n"
"PO-Revision-Date: #{time}\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\\n"]
    end

    def generate_pot(ary) # :nodoc:
      str = ""
      result = Array.new
      ary.each do |key|
	msgid = key.shift
	curr_pos = MAX_LINE_LEN
	key.each do |e|
	  if curr_pos + e.size > MAX_LINE_LEN
	    str << "\n#:"
	    curr_pos = 3
	  else
	    curr_pos += (e.size + 1)
	  end
	  str << " " << e
	end
	msgid.gsub!(/"/, '\"')
	msgid.gsub!(/\r/, '')
	if msgid.include?("\004")
	  msgctxt, msgid = msgid.split(/\004/)
	  str << "\nmsgctxt \"" << msgctxt << "\"\n"
        else
          str << "\n"
	end	
	if msgid.include?("\000")
	  ids = msgid.split(/\000/)
	  str << "msgid \"" << ids[0] << "\"\n"
	  str << "msgid_plural \"" << ids[1] << "\"\n"
	  str << "msgstr[0] \"\"\n"
	  str << "msgstr[1] \"\"\n"
	else
	  str << "msgid \"" << msgid << "\"\n"
	  str << "msgstr \"\"\n"
	end
      end
      str
    end

    def normalize(ary)  # :nodoc:
      used_plural_msgs = []
      ary.select{|item| item[0].include? "\000"}.each do |plural_msg|
        next if used_plural_msgs.include?(plural_msg[0])

        key = plural_msg[0].split("\000")[0]

        ary.dup.each do |single_msg|
          if single_msg[0] == key or
              (single_msg[0] =~ /^#{Regexp.quote(key)}\000/ and 
               single_msg[0] != plural_msg[0])
            if single_msg[0] != key 
              warn %Q[Warning: n_("#{plural_msg[0].gsub(/\000/, '", "')}") and n_("#{single_msg[0].gsub(/\000/, '", "')}") are duplicated. First msgid was used.] 
                used_plural_msgs << single_msg[0]
            end

            single_msg[1..-1].each do |line_info|
              plural_msg << line_info
              fname = line_info.split(/:/)[0]
              sorted = plural_msg[1..-1].select{|l| l.split(/:/)[0].include?(fname)}.collect{|l| 
                aline = l.split(/:/)
                [aline[0], aline[1] =~ /[0-9]+/ ? aline[1].to_i : aline[1]]
              }.sort.collect{|l| "#{l[0]}:#{l[1]}"}
              plural_msg.delete_if{|i| sorted.include?(i)}
              sorted.each {|i|
                plural_msg << i
              }
            end
            ary.delete(single_msg)
          end
        end
      end
      ary.collect{|i| i.uniq}
    end

    def parse(files) # :nodoc:
      ary = []
      files.each do |file|
	begin
	  @ex_parsers.each do |klass|
	    if klass.target?(file)
	      ary = klass.parse(file, ary)
	      break
	    end
	  end
	rescue
	  puts "Error occurs in " + file
	  raise
	end
      end
      normalize(ary)
    end

    def check_options # :nodoc:
      output = STDOUT

      opts = OptionParser.new
      opts.banner = _("Usage: %s input.rb [-r parser.rb] [-o output.pot]") % $0
      opts.separator("")
      opts.separator(_("Extract translatable strings from given input files."))
      opts.separator("")
      opts.separator(_("Specific options:"))

      opts.on("-o", "--output=FILE", _("write output to specified file")) do |out|
	unless FileTest.exist? out
	  output = File.new(File.expand_path(out), "w+")
	else
	  $stderr.puts(_("File '%s' already exists.") % out)
	  exit 1
	end
      end

      opts.on("-r", "--require=library", _("require the library before executing rgettext")) do |out|
	require out
      end

      opts.on("-d", "--debug", _("run in debugging mode")) do
	$DEBUG = true
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

      [ARGV, output]
    end

    def run(targetfiles = nil, out = STDOUT)  # :nodoc:
      if targetfiles.is_a? String
	targetfiles = [targetfiles]
      elsif ! targetfiles
	targetfiles, out = check_options
      end

      if targetfiles.size == 0
	raise ArgumentError, _("no input files")
      end

      if out.is_a? String
	File.open(File.expand_path(out), "w+") do |file|
	  file.puts generate_pot_header
	  file.puts generate_pot(parse(targetfiles))
	end
      else
	out.puts generate_pot_header
	out.puts generate_pot(parse(targetfiles))
      end
      self
    end
  end

  module_function
  # Creates a po-file from targetfiles(ruby-script-files, ActiveRecord, .rhtml files, glade-2 XML files), 
  # then output the result to out. If no parameter is set, it behaves same as command line tools(rgettet). 
  #
  # This function is a part of GetText.create_pofiles.
  # Usually you don't need to call this function directly.
  #
  # *Note* for ActiveRecord, you need to run your database server and configure the config/database.xml 
  # correctly before execute this function.
  #
  # * targetfiles: An Array of po-files or nil.
  # * out: output IO or output path.
  # * Returns: self
  def rgettext(targetfiles = nil, out = STDOUT)
    RGetText.run(targetfiles, out)
    self
  end
end

if $0 == __FILE__
  GetText.rgettext
#  GetText.rgettext($0, "tmp.txt")
end
