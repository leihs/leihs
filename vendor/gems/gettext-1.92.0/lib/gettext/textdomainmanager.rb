=begin
  textdomainmanager.rb - Manage TextDomains.

  Copyright (C) 2006  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: textdomainmanager.rb,v 1.6 2008/01/29 16:30:29 mutoh Exp $
=end

require 'locale'
require 'gettext/textdomain'

module GetText
  # Manage TextDomain (Internal use only)
  # A class/module is able to have plural textdomains.
  class TextDomainManager
    include Enumerable

    attr_reader :target, :textdomains

    @@output_charset = ENV["OUTPUT_CHARSET"]
    @@textdomain_all = {}

    # Sets the current output_charset.
    # * charset: output_charset.
    # * Returns: output_charset.
    def self.output_charset=(charset)
      @@output_charset = charset
    end

    # Gets the current output_charset.
    # * Returns: output_charset.
    def self.output_charset
      @@output_charset 
    end

    def self.each_all
      @@textdomain_all.each do |k, textdomain|
	yield textdomain
      end
    end

    def self.textdomain(domainname)
      @@textdomain_all[domainname]
    end

    # Initialize a TextDomainManager
    # * target: a target class/module to bind this TextDomainManager. 
    # * locale: a Locale::Object.
    def initialize(target, locale)
      @target = target
      @locale = locale
      @textdomains = {}
    end

    # Add a textdomain
    # * options: If they aren't set or invalid, default values are used. 
    #   * :path - the path to the mo-files. If not set, it will search default paths such as 
    #     /usr/share/locale, /usr/local/share/locale)
    def add_textdomain(domainname, options = {})
      path = options[:path]
      if $DEBUG
	$stderr.print "Bind the domain '#{domainname}' to '#{@target}'. "
	$stderr.print "Current locale is #{@locale.inspect}\n"
      end
      textdomain = @@textdomain_all[domainname]
      if textdomain
	textdomain.set_locale(@locale)
      else
	textdomain = TextDomain.new(domainname, path, @locale)
	@@textdomain_all[domainname] = textdomain
      end
	@textdomains[domainname] = textdomain
      textdomain
    end

    # Iterate textdomains.
    def each
      @textdomains.each do |k, textdomain|
	yield textdomain
      end
      self
    end

    # Sets locale such as "de", "fr", "it", "ko", "ja_JP.eucJP", "zh_CN.EUC" ... 
    #
    # Notice that you shouldn't use this for your own Libraries.
    # * locale: a locale string or Locale::Object.
    # * force: Change locale forcely.
    # * Returns: self
    def set_locale(locale, force = false)
      if locale != @locale or force
	each do |textdomain|
	  textdomain.set_locale(locale, force)
	end
	@locale = locale
      end
      self
    end
  end
end
