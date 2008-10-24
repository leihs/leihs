=begin
  gettext.rb - GetText module

  Copyright (C) 2001-2008  Masao Mutoh
  Copyright (C) 2001-2003  Masahiro Sakai

      Masao Mutoh       <mutoh@highway.ne.jp>
      Masahiro Sakai    <s01397ms@sfc.keio.ac.jp>

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: gettext.rb,v 1.46 2008/09/13 18:23:55 mutoh Exp $
=end

require 'rbconfig'
require 'gettext/version'
require 'gettext/mo'
require 'locale'
require 'gettext/textdomainmanager'
require 'gettext/string'

module GetText
  # If the textdomain isn't bound when calling GetText.textdomain, this error is raised.
  class NoboundTextDomainError < RuntimeError
  end

  def self.included(mod)  #:nodoc:
    mod.extend self
  end

  # Max cached object_ids includes dead objects.
  CACHE_BOUND_TARGET_MAX_SIZE = 50000 #:nodoc:

  @@__cached = ! $DEBUG

  # Set the value whether cache messages or not. 
  # true to cache messages, otherwise false.
  #
  # Default is true. If $DEBUG is false, messages are not checked even if
  # this value is true.
  def cached=(val)
    @@__cached = val
    GetText::TextDomain.check_mo = ! val
  end

  # Return the cached value.
  def cached?
    @@__cached
  end
  
  # Clear the cached messages.
  def clear_cache
    @@__cache_msgids = {}
    @@__cache_nmsgids = {}
    @@__cache_target_classes = {}
    @@__cache_bound_target = {}
    @@__cache_bound_targets = {}
  end

  @@__textdomainmanagers = {}

  # call-seq:
  # bindtextdomain(domainname, options = {})
  #
  # Bind a textdomain(%{path}/%{locale}/LC_MESSAGES/%{domainname}.mo) to your program.
  # Normally, the texdomain scope becomes a ruby-script-file. 
  # So you need to call this function each ruby-script-files. 
  # On the other hand, if you call this function under GetText::Container 
  # (gettext/container, gettext/erb, gettext/rails), the textdomain scope becomes a Class/Module.
  # * domainname: the textdomain name.
  # * options: options as an Hash.
  #   * :path - the path to the mo-files. When the value is nil, it will search default paths such as 
  #     /usr/share/locale, /usr/local/share/locale)
  #   * :locale - the locale string such as "ja_JP.UTF-8".  Generally, you should use GetText.set_locale instead.
  #     The value is searched order by:
  #     the value of this value > System default language.
  #   * :charset - output charset.  This affect the current textdomain only. Generally, you should use GetText.set_output_charset instead.
  #     The value is searched order by:
  #     the value of Locale.set_output_charset > ENV["OUTPUT_CHARSET"] > this value > System default charset.
  # * Returns: the GetText::TextDomainManager.
  # Note: Don't use locale_, charset argument(not in options). 
  # They are remained for backward compatibility. 
  #
  def bindtextdomain(domainname, options = {}, locale_ = nil, charset = nil)
    opt = {}
    if options.kind_of? String
      # For backward compatibility
      opt = {:path => options, :locale => locale_, :charset => charset}
    elsif options
      opt = options
    end
    opt[:locale] = opt[:locale] ? Locale::Object.new(opt[:locale]) : Locale.get
    opt[:charset] = TextDomainManager.output_charset if TextDomainManager.output_charset
    opt[:locale].charset = opt[:charset] if opt[:charset]
    Locale.set_current(opt[:locale])
    target_key = bound_target
    manager = @@__textdomainmanagers[target_key]
    if manager
      manager.set_locale(opt[:locale]) 
    else
      manager = TextDomainManager.new(target_key, opt[:locale])
      @@__textdomainmanagers[target_key] = manager
    end
    manager.add_textdomain(domainname, opt)
    manager
  end

  # Includes GetText module and bind a textdomain to a class.
  # * klass: the target ruby class.
  # * domainname: the textdomain name.
  # * options: options as an Hash. See GetText.bindtextdomain.
  def bindtextdomain_to(klass, domainname, options = {}) 
    ret = nil
    klass.module_eval {
      include GetText
      ret = bindtextdomain(domainname, options)
    }
    ret
  end

  # Binds a existed textdomain to your program. 
  # This is the same function with GetText.bindtextdomain but simpler(and faster) than bindtextdomain.
  # Notice that you need to call GetText.bindtextdomain first. If the domainname hasn't bound yet, 
  # raises GetText::NoboundTextDomainError.
  # * domainname: a textdomain name.
  # * Returns: the GetText::TextDomainManager.
  def textdomain(domainname)
    domain = TextDomainManager.textdomain(domainname)
    raise NoboundTextDomainError, "#{domainname} is not bound." unless domain
    target_key = bound_target
    manager = @@__textdomainmanagers[target_key]
    unless manager
      manager = TextDomainManager.new(target_key, Locale.get)
      @@__textdomainmanagers[target_key] = manager
    end
    manager.set_locale(Locale.get)
    manager.add_textdomain(domainname)
    manager
  end

  # Includes GetText module and bind an exsited textdomain to a class. 
  # See textdomain for more detail.
  # * klass: the target ruby class.
  # * domainname: the textdomain name.
  def textdomain_to(klass, domainname) 
    ret = nil
    klass.module_eval {
      include GetText
      ret = textdomain(domainname)
    }
    ret
  end

  # Iterates bound textdomains.
  # * klass: a class/module to find. Default is the class of self.
  # * ignore_targets: Ignore tragets.
  # * Returns: a bound GetText::TextDomain or nil.
  def each_textdomain(klass = self, ignore_targets = []) #:nodoc:
    bound_targets(klass).each do |target|
      unless ignore_targets.include? target
	manager = @@__textdomainmanagers[target]
	if manager
	  manager.each{ |textdomain|
	    yield textdomain
	  }
	end
      end
    end
    self
  end

  @@__cache_target_classes = {}

  def find_targets(klass)  #:nodoc:
    unless (klass.kind_of? Class or klass.kind_of? Module)
      klass = klass.class
    end
    id = klass.object_id
    if cached?
      return @@__cache_target_classes[id] if @@__cache_target_classes[id]
    end

    ret = []
    ary = klass.name.split(/::/)
    while(v = ary.shift)
      if ret.size == 0
        if v.kind_of? Class
          target = v
        else
          target = eval(v)
          return [Object] unless (target = eval(v)) # For anonymous module
        end
      else
        target = ret[0].const_get(v)
      end
      ret.unshift(target) if target
    end
    @@__cache_target_classes[id] = ret.size > 0 ? ret : [klass]
  end

  @@__cache_bound_target = {}

  def bound_target(klass = self) # :nodoc:
    ret = (klass.kind_of? Module) ? klass : klass.class
    id = ret.object_id
    if cached?
     tgt = @@__cache_bound_target[id]
     return tgt if tgt
    end

    if ret.name =~ /^\#<|^$/ or ret == GetText
       #GC for dead object_ids.
       ret = Object
       if @@__cache_bound_target.size > CACHE_BOUND_TARGET_MAX_SIZE
          @@__cache_bound_target.clear
       end
    end
    @@__cache_bound_target[id] = ret
    ret
  end

  @@__cache_bound_targets = {}

  def bound_targets(klass)  # :nodoc:
    id = klass.object_id
    if cached?
      if @@__cache_bound_targets[id]
        return @@__cache_bound_targets[id]
      end
    end
    ret = []
    klass = bound_target(klass)
    ary = klass.name.split(/::/)
    while(v = ary.shift)
      ret.unshift(((ret.size == 0) ? eval(v) : ret[0].const_get(v)))
    end
    @@__cache_bound_targets[id] = ((ret + klass.ancestors + [Object]) & @@__textdomainmanagers.keys).uniq
  end
 
  @@__cache_msgids = {}

  # call-seq:
  #   gettext(msgid)
  #   _(msgid)
  #
  # Translates msgid and return the message.
  # This doesn't make a copy of the message. 
  #
  # You need to use String#dup if you want to modify the return value 
  # with destructive functions. 
  #
  # (e.g.1) _("Hello ").dup << "world"
  # 
  # But e.g.1 should be rewrite to:
  #
  # (e.g.2) _("Hello %{val}") % {:val => "world"}
  #
  # Because the translator may want to change the position of "world".
  #
  # * msgid: the message id.
  # * Returns: localized text by msgid. If there are not binded mo-file, it will return msgid.
  def gettext(msgid)
    sgettext(msgid, nil)
  end

  # call-seq:
  #   sgettext(msgid, div = '|')
  #   s_(msgid, div = '|')
  #
  # Translates msgid, but if there are no localized text, 
  # it returns a last part of msgid separeted "div".
  #
  # * msgid: the message id.
  # * div: separator or nil.
  # * Returns: the localized text by msgid. If there are no localized text, 
  #   it returns a last part of msgid separeted "div".
  # See: http://www.gnu.org/software/gettext/manual/html_mono/gettext.html#SEC151
  def sgettext(msgid, div = '|')
    cached_key = [bound_target, Locale.current, msgid]
    if cached?
      if @@__cache_msgids[cached_key]
        return @@__cache_msgids[cached_key]
      end
    end
    msg = nil

    # Use "for"(not "each") to support JRuby 1.1.0.
    for target in bound_targets(self)
      manager = @@__textdomainmanagers[target]
      for textdomain in manager.textdomains
        msg = textdomain[1].gettext(msgid)
        break if msg
      end
      break if msg
    end

    msg ||= msgid
    if div and msg == msgid
      if index = msg.rindex(div)
	msg = msg[(index + 1)..-1]
      end
    end
    @@__cache_msgids[cached_key] = msg
  end

  # call-seq:
  #   pgettext(msgctxt, msgid)
  #   p_(msgctxt, msgid)
  #
  # Translates msgid with msgctxt. This methods is similer with s_().
  #  e.g.) p_("File", "New")   == s_("File|New")
  #        p_("File", "Open")  == s_("File|Open")
  #
  # * msgctxt: the message context.
  # * msgid: the message id.
  # * Returns: the localized text by msgid. If there are no localized text, 
  #   it returns msgid.
  # See: http://www.gnu.org/software/autoconf/manual/gettext/Contexts.html
  def pgettext(msgctxt, msgid)
    sgettext(msgctxt + "\004" + msgid, "\004")
  end

  @@__cache_nmsgids = {}

  # call-seq:
  #   ngettext(msgid, msgid_plural, n)
  #   ngettext(msgids, n)  # msgids = [msgid, msgid_plural]
  #   n_(msgid, msgid_plural, n)
  #   n_(msgids, n)  # msgids = [msgid, msgid_plural]
  #
  # The ngettext is similar to the gettext function as it finds the message catalogs in the same way. 
  # But it takes two extra arguments for plural form.
  #
  # * msgid: the singular form.
  # * msgid_plural: the plural form.
  # * n: a number used to determine the plural form.
  # * Returns: the localized text which key is msgid_plural if n is plural(follow plural-rule) or msgid.
  #   "plural-rule" is defined in po-file.
  def ngettext(arg1, arg2, arg3 = nil)
    nsgettext(arg1, arg2, arg3, nil)
  end

  # call-seq:
  #   npgettext(msgctxt, msgid, msgid_plural, n)
  #   npgettext(msgctxt, msgids, n)  # msgids = [msgid, msgid_plural]
  #   np_(msgctxt, msgid, msgid_plural, n)
  #   np_(msgctxt, msgids, n)  # msgids = [msgid, msgid_plural]
  #
  # The npgettext is similar to the nsgettext function.
  #   e.g.) np_("Special", "An apple", "%{num} Apples", num) == ns_("Special|An apple", "%{num} Apples", num)
  # * msgctxt: the message context.
  # * msgid: the singular form.
  # * msgid_plural: the plural form.
  # * n: a number used to determine the plural form.
  # * Returns: the localized text which key is msgid_plural if n is plural(follow plural-rule) or msgid.
  #   "plural-rule" is defined in po-file.
  def npgettext(msgctxt, arg1, arg2 = nil, arg3 = nil)
    if arg1.kind_of?(Array)
      msgid = arg1[0]
      msgid_ctxt = "#{msgctxt}\004#{msgid}"
      msgid_plural = arg1[1]
      opt1 = arg2
      opt2 = arg3
    else
      msgid = arg1
      msgid_ctxt = "#{msgctxt}\004#{msgid}"
      msgid_plural = arg2
      opt1 = arg3
      opt2 = nil
    end
    ret = nsgettext(msgid_ctxt, msgid_plural, opt1, opt2)
    
    if ret == msgid_ctxt
      ret = msgid
    end
    ret
  end

  # This function does nothing. But it is required in order to recognize the msgid by rgettext.
  # * msgid: the message id.
  # * Returns: msgid.
  def N_(msgid)
    msgid
  end

  # This is same function as N_ but for ngettext. 
  # * msgid: the message id.
  # * msgid_plural: the plural message id.
  # * Returns: msgid.
  def Nn_(msgid, msgid_plural)
    [msgid, msgid_plural]
  end


  # call-seq:
  #   nsgettext(msgid, msgid_plural, n, div = "|")
  #   nsgettext(msgids, n, div = "|")  # msgids = [msgid, msgid_plural]
  #   n_(msgid, msgid_plural, n, div = "|")
  #   n_(msgids, n, div = "|")  # msgids = [msgid, msgid_plural]
  #
  # The nsgettext is similar to the ngettext.
  # But if there are no localized text, 
  # it returns a last part of msgid separeted "div".
  #
  # * msgid: the singular form with "div". (e.g. "Special|An apple")
  # * msgid_plural: the plural form. (e.g. "%{num} Apples")
  # * n: a number used to determine the plural form.
  # * Returns: the localized text which key is msgid_plural if n is plural(follow plural-rule) or msgid.
  #   "plural-rule" is defined in po-file.
  def nsgettext(arg1, arg2, arg3 = "|", arg4 = "|")
    if arg1.kind_of?(Array)
      msgid = arg1[0]
      msgid_plural = arg1[1]
      n = arg2
      if arg3 and arg3.kind_of? Numeric
        raise ArgumentError, _("3rd parmeter is wrong: value = %{number}") % {:number => arg3}
      end
      div = arg3
    else
      msgid = arg1
      msgid_plural = arg2
      n = arg3
      div = arg4
    end

    cached_key = [bound_target, Locale.current, msgid + "\000" + msgid_plural]
    msgs = nil
    if @@__cached
      if @@__cache_nmsgids.has_key?(cached_key)
        msgs = @@__cache_nmsgids[cached_key]  # [msgstr, cond_as_string]
      end
    end
    unless msgs
      # Use "for"(not "each") to support JRuby 1.1.0.
      for target in bound_targets(self)
        manager = @@__textdomainmanagers[target]
        for textdomain in manager.textdomains
          msgs = textdomain[1].ngettext_data(msgid, msgid_plural)
          break if msgs
        end
        break if msgs
      end
      msgs = [[msgid, msgid_plural], "n != 1"] unless msgs
      @@__cache_nmsgids[cached_key] = msgs
    end
    msgstrs = msgs[0]
    if div and msgstrs[0] == msgid
      if index = msgstrs[0].rindex(div)
	msgstrs[0] = msgstrs[0][(index + 1)..-1]
      end
    end
    plural = eval(msgs[1])
    if plural.kind_of?(Numeric)
      ret = msgstrs[plural]
    else
      ret = plural ? msgstrs[1] : msgstrs[0]
    end
    ret
  end

  # Sets the current locale to the current class/module
  #
  # Notice that you shouldn't use this for your own Libraries.
  # * locale: a locale string or Locale::Object.
  # * this_target_only: true if you want to change the current class/module only.
  # Otherwise, this changes the locale of the current class/module and its ancestors.
  # Default is false.
  # * Returns: self
  def set_locale(locale, this_target_only = false)
    ret = nil
    if locale
      if locale.kind_of? Locale::Object
	ret = locale
      else
	ret = Locale::Object.new(locale.to_s)
      end
      ret.charset = TextDomainManager.output_charset if TextDomainManager.output_charset
      Locale.set(ret)
    else
      Locale.set(nil)
      ret = Locale.get
    end
    if this_target_only
      manager = @@__textdomainmanagers[bound_target]
      if manager
	manager.set_locale(ret, ! cached?)
      end
    else
      each_textdomain {|textdomain|
        textdomain.set_locale(ret, ! cached?)
      }
    end
    self
  end

  # Sets current locale to the all textdomains.
  #
  # Note that you shouldn't use this for your own Libraries.
  # * locale: a locale string or Locale::Object, otherwise nil to use default locale.
  # * Returns: self
  def set_locale_all(locale)
    ret = nil
    if locale
      if locale.kind_of? Locale::Object
	ret = locale
      else
	ret = Locale::Object.new(locale.to_s)
      end
    else
      ret = Locale.default
    end
    ret.charset = TextDomainManager.output_charset if TextDomainManager.output_charset
    Locale.set_current(ret)
    TextDomainManager.each_all {|textdomain|
      textdomain.set_locale(ret, ! cached?)
    }
    self
  end

  # Sets the default/current locale. This method haves the strongest infulence.
  # All of the Textdomains are set the new locale. 
  #
  # Note that you shouldn't use this for your own Libraries.
  # * locale: a locale string or Locale::Object
  # * Returns: a locale string
  def locale=(locale)
    Locale.default = locale
    set_locale_all(locale)
    Locale.default
  end

  # Sets charset(String) such as "euc-jp", "sjis", "CP932", "utf-8", ... 
  # You shouldn't use this in your own Libraries.
  # * charset: an output_charset
  # * Returns: charset
  def set_output_charset(charset)
    TextDomainManager.output_charset = charset
    self
  end

  # Same as GetText.set_output_charset
  # * charset: an output_charset
  # * Returns: charset
  def output_charset=(charset)
    TextDomainManager.output_charset = charset
  end

  # Gets the current output_charset which is set using GetText.set_output_charset.
  # * Returns: output_charset.
  def output_charset
    TextDomainManager.output_charset || locale.charset
  end

  # Gets the current locale.
  # * Returns: a current Locale::Object
  def locale
    Locale.current
  end

  # Add default locale path.
  # * path: a new locale path. (e.g.) "/usr/share/locale/%{locale}/LC_MESSAGES/%{name}.mo"
  #   ('locale' => "ja_JP", 'name' => "textdomain")
  # * Returns: the new DEFAULT_LOCALE_PATHS
  def add_default_locale_path(path)
    TextDomain.add_default_locale_path(path)
  end

  # Show the current textdomain information. This function is for debugging.
  # * options: options as a Hash.
  #   * :with_messages - show informations with messages of the current mo file. Default is false.
  #   * :out - An output target. Default is STDOUT.
  #   * :with_paths - show the load paths for mo-files.
  def current_textdomain_info(options = {})
    opts = {:with_messages => false, :with_paths => false, :out => STDOUT}.merge(options)
    ret = nil
    each_textdomain {|textdomain|
      opts[:out].puts "TextDomain name: \"#{textdomain.name}\""
      opts[:out].puts "TextDomain current locale: \"#{textdomain.current_locale}\""
      opts[:out].puts "TextDomain current mo filename: \"#{textdomain.current_mo.filename}\""
      if opts[:with_paths]
	opts[:out].puts "TextDomain locale file paths:"
	textdomain.locale_paths.each do |v|
	  opts[:out].puts "  #{v}"
	end
      end
      if opts[:with_messages]
	opts[:out].puts "The messages in the mo file:"
	textdomain.current_mo.each{|k, v|
	  opts[:out].puts "  \"#{k}\": \"#{v}\""
	}
      end
    }
  end

  # for testing.
  def remove_all_textdomains
    clear_cache
    @@__textdomainmanagers = {}
  end

  alias :setlocale :locale= #:nodoc:
  alias :_ :gettext   #:nodoc:
  alias :n_ :ngettext #:nodoc:
  alias :s_ :sgettext #:nodoc:
  alias :ns_ :nsgettext #:nodoc:
  alias :np_ :npgettext #:nodoc:

unless defined? "XX"
  # This is the workaround to conflict p_ methods with the xx("double x") library.
  # http://rubyforge.org/projects/codeforpeople/
  alias :p_ :pgettext #:nodoc:
  module_function :p_
end

  module_function :bindtextdomain, :textdomain, :each_textdomain, :cached=, :cached?, :clear_cache, 
  :N_, :gettext, :_, :ngettext, :n_, :sgettext, :s_, :nsgettext, :ns_, :pgettext, :npgettext, :np_,
  :bound_target, :bound_targets, :find_targets,
  :setlocale, :set_locale, :locale=, :set_locale_all, :locale, 
  :set_output_charset, :output_charset=, :output_charset, :current_textdomain_info, :remove_all_textdomains 
end
