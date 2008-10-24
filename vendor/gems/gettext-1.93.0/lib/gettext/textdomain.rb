=begin
  textdomain.rb - GetText::Textdomain

  Copyright (C) 2001-2008  Masao Mutoh
  Copyright (C) 2001-2003  Masahiro Sakai

      Masahiro Sakai    <s01397ms@sfc.keio.ac.jp>
      Masao Mutoh       <mutoh@highway.ne.jp>

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: textdomain.rb,v 1.24 2008/03/31 06:26:47 mutoh Exp $
=end

require 'gettext/string'
require 'rbconfig'

module GetText
  # GetText::TextDomain class manages mo-files of a textdomain. 
  # 
  # Usually, you don't need to use this class directly.
  #
  # Notice: This class is unstable. APIs will be changed.
  class TextDomain

    GEM_PATH_RE = /(.*)\/lib$/  # :nodoc:

    attr_reader :current_locale
    attr_reader :locale_paths
    attr_reader :current_mo
    attr_reader :name

    @@check_mo = false
    # Check mo-file is modified or not, and if mo-file is modified,
    # reload mo-file again. This is effective in debug mode.
    # Default is false. If $DEBUG is true, mo-file is checked even if
    # this value is false.
    # * Returns: true if "check mo" mode.
    def self.check_mo?
      @@check_mo
    end

    # Sets to check mo-file or not. See GetText::TextDoman.check_mo? for more details.
    # * val: true if "check mo" mode.
    # * Returns: val
    def self.check_mo=(val)
      @@check_mo = val
    end
    # The default locale paths.
    CONFIG_PREFIX = Config::CONFIG['prefix'].gsub(/\/local/, "")
    DEFAULT_LOCALE_PATHS = [
      "#{Config::CONFIG['datadir']}/locale/%{locale}/LC_MESSAGES/%{name}.mo",
      "#{Config::CONFIG['datadir'].gsub(/\/local/, "")}/locale/%{locale}/LC_MESSAGES/%{name}.mo",
      "#{CONFIG_PREFIX}/share/locale/%{locale}/LC_MESSAGES/%{name}.mo",
      "#{CONFIG_PREFIX}/local/share/locale/%{locale}/LC_MESSAGES/%{name}.mo"
    ].uniq

    # Add default locale path. Usually you should use GetText.add_default_locale_path instead.
    # * path: a new locale path. (e.g.) "/usr/share/locale/%{locale}/LC_MESSAGES/%{name}.mo"
    #   ('locale' => "ja_JP", 'name' => "textdomain")
    # * Returns: the new DEFAULT_LOCALE_PATHS
    def self.add_default_locale_path(path)
      DEFAULT_LOCALE_PATHS.unshift(path)
    end

    # Creates a new GetText::TextDomain.
    # * name: the textdomain name.
    # * topdir: the locale path ("%{topdir}/%{locale}/LC_MESSAGES/%{name}.mo").
    # * locale: the Locale::Object or nil.
    # * Returns: a newly created GetText::TextDomain object.
    def initialize(name, topdir = nil, locale = nil)
      @name, @topdir = name, topdir
      @search_files = Array.new

      @locale_paths = []
      if ENV["GETTEXT_PATH"]
        ENV["GETTEXT_PATH"].split(/,/).each {|i| 
      @locale_paths += ["#{i}/%{locale}/LC_MESSAGES/%{name}.mo", "#{i}/%{locale}/%{name}.mo"]
    }
      elsif @topdir
        @locale_paths += ["#{@topdir}/%{locale}/LC_MESSAGES/%{name}.mo", "#{@topdir}/%{locale}/%{name}.mo"]
      end

      unless @topdir
    @locale_paths += DEFAULT_LOCALE_PATHS
    
    if defined? Gem
      $:.each do |path|
        if GEM_PATH_RE =~ path
          @locale_paths += [
        "#{$1}/data/locale/%{locale}/LC_MESSAGES/%{name}.mo", 
        "#{$1}/data/locale/%{locale}/%{name}.mo", 
        "#{$1}/locale/%{locale}/%{name}.mo"]
        end
      end
    end
      end
   
      @mofiles = Hash.new
      set_locale(locale)
    end
    
    # Sets a new Locale::Object.
    # * locale: a Locale::Object
    # * reload: true if the mo-file is reloaded forcely
    # * Returns: self
    def set_locale(locale, reload = false)
      @current_locale = locale
      load_mo(reload)
      self
    end

    # Gets the translated string.
    # * msgid: the original message.
    # * Returns: the translated string or nil if not found.
    def gettext(msgid)
      return "" if msgid == "" or msgid.nil?
      return nil unless @current_mo
      if @current_mo[msgid] and (@current_mo[msgid].size > 0)
        @current_mo[msgid]
      elsif msgid.include?("\000")
        ret = nil
        msgid_single = msgid.split("\000")[0]
        @current_mo.each{|key, val| 
          if key =~ /^#{Regexp.quote(msgid_single)}\000/
              # Usually, this is not caused to make po-files from rgettext.
              warn %Q[Warning: n_("#{msgid_single}", "#{msgid.split("\000")[1]}") and n_("#{key.gsub(/\000/, '", "')}") are duplicated.] if $DEBUG
            ret = val
            break
          end
        }
        ret
      else
        ret = nil
        @current_mo.each{|key, val| 
          if key =~ /^#{Regexp.quote(msgid)}\000/
              ret = val.split("\000")[0]
            break
          end
        }
        ret
      end
    end

    # Gets the translated string. (Deprecated. Don't call this method directly)
    # * msgid: the original message(single).
    # * msgid: the original message(plural).
    # * n: the number
    # * Returns: the translated string or nil if not found.
    def ngettext(msgid, msgid_plural, n)
      key = msgid + "\000" + msgid_plural
      msg = gettext(key)
      if ! msg
    nil  # do nothing.
      elsif msg == key
    msg = n == 1 ? msgid : msgid_plural
      elsif msg.include?("\000")
        ary = msg.split("\000")
        if @current_mo
          plural = eval(@current_mo.plural)
          if plural.kind_of?(Numeric)
            msg = ary[plural]
          else
            msg = plural ? ary[1] : ary[0]
          end
        else
          msg = n == 1 ? ary[0] : ary[1]
        end
      end
      msg
    end

    def ngettext_data(msgid, msgid_plural)   #:nodoc:
      key = msgid + "\000" + msgid_plural
      msg = gettext(key)
      ret = nil
      if ! msg
        ret = nil
      elsif msg == key
        ret = nil
      elsif msg.include?("\000")
        # [[msgstr[0], msgstr[1], msgstr[2],...], cond]
        cond = @current_mo ? @current_mo.plural : nil
        cond ||= "n != 1"
        ret = [msg.split("\000"), cond]
      else
        ret = [[msg], "0"]
      end
      ret
    end

    # Compare this object has the same name, topdir and locale.
    # * name: the textdomain name
    # * topdir: the top directory of mo files or nil.
    # * locale: the Locale::Object or nil.
    # * Returns: true if this object has all of the same name, topdir and locale. 
    def same_property?(name, topdir, locale)
      @name == name and @topdir == topdir and @current_locale == locale
    end
    
    private
    def load_mo(reload = false)
      @current_mo = nil
      return nil unless @current_locale

      unless reload
        @current_mo = @mofiles[@current_locale]
        if @current_mo
          if @current_mo == :empty
            @current_mo = nil
            return nil unless (@@check_mo or $DEBUG)
          elsif (@@check_mo or $DEBUG)
            @current_mo.update!
            return @current_mo
          else
            return @current_mo
          end
        end
      end
      locales = [@current_locale.orig_str, @current_locale.to_posix, @current_locale.language].uniq
      matched = false
      @locale_paths.each do |dir|
        locales.each{|locale|
          fname = dir % {:locale => locale, :name => @name}
          if $DEBUG
            @search_files << fname unless @search_files.include?(fname)
          end
          if File.exist?(fname)
            $stderr.puts "GetText::TextDomain#load_mo: mo file is #{fname}" if $DEBUG
            @current_mo = MOFile.open(fname, @current_locale.charset)
            @mofiles[@current_locale] = @current_mo
            matched = true
            break
          end
        }
        break if matched
      end
      unless @current_mo
        @mofiles[@current_locale] = :empty
        if $DEBUG
          $stderr.puts "MO file is not found in"
          @search_files.each do |v|
            $stderr.puts "  #{v}"
          end
        end
      end
      @current_mo
    end
  end
end
