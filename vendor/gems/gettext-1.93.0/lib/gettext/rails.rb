=begin
  gettext/rails.rb - GetText for "Ruby on Rails"

  Copyright (C) 2005-2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: rails.rb,v 1.81 2008/09/13 18:23:56 mutoh Exp $
=end

require 'gettext/cgi'
require 'action_controller'
require 'gettext/rails_compat'

module GetText
  # GetText::Rails supports Ruby on Rails.
  # You add only 2 lines in your controller, all of the controller/view/models are
  # targeted the textdomain. 
  #
  # See <Ruby-GetText-Package HOWTO for Ruby on Rails (http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html>.
  module Rails
    include GetText

    Rails = ::Rails  #:nodoc:

    alias :_bindtextdomain :bindtextdomain #:nodoc:

    def self.included(mod)  #:nodoc:
      mod.extend self
    end

    module_function
    # call-seq:
    # bindtextdomain(domainname, options = {})
    #
    # Bind a textdomain(#{path}/#{locale}/LC_MESSAGES/#{domainname}.mo) to your program. 
    # Notes the textdomain scope becomes all of the controllers/views/models in your app. 
    # This is different from normal GetText.bindtextomain.
    #
    # Usually, you don't call this directly in your rails application.
    # Call init_gettext in ActionController::Base instead.
    #
    # On the other hand, you need to call this in helpers/plugins.
    #
    # * domainname: the textdomain name.
    # * options: options as a Hash.
    #   * :locale - the locale value such as "ja-JP". When the value is nil, 
    #     locale is searched the order by this value > "lang" value of QUERY_STRING > 
    #     params["lang"] > "lang" value of Cookie > HTTP_ACCEPT_LANGUAGE value 
    #     > Default locale(en). 
    #   * :path - the path to the mo-files. Default is "RAIL_ROOT/locale".
    #   * :charset - the charset. Generally UTF-8 is recommanded.
    #     And the charset is set order by "the argument of bindtextdomain" 
    #     > HTTP_ACCEPT_CHARSET > Default charset(UTF-8).
    #
    #
    def bindtextdomain(domainname, options = {})
      options[:path] ||= File.join(RAILS_ROOT, "locale")
      _bindtextdomain(domainname, options)
    end

    @@available_locales = nil
    # Returns locales which supported by the application.
    # This function returns an reversed array of the locale strings under RAILS_ROOT/locale/*.
    # It is used for restriction such as caching files.
    def available_locales
      unless (GetText.cached? and @@available_locales)
        @@available_locales = (Dir.glob(File.join(RAILS_ROOT, "locale/[a-z]*")).map{|path| File.basename(path)} << "en").uniq.sort.reverse
      end
      @@available_locales
    end

    # Returns a normalized locale which is in available_locales.
    # * locale: a Locale::Object or nil.
    def normalized_locale(locale = nil)
      locale ||= GetText.locale
      (available_locales &
        [locale.to_general, locale.to_s, locale.language, Locale.default.language, "en"].uniq)[0]
    end

  end
end

module ActionController #:nodoc:
  class Base
    helper GetText::Rails
    include GetText::Rails

    @@gettext_domainnames = []
    @@gettext_content_type = nil
    
    prepend_before_filter :init_gettext
    after_filter :init_content_type
     
    def init_gettext_main(cgi) #:nodoc:
      cgi.params["lang"] = [params["lang"]] if params["lang"]
      set_cgi(cgi)
      set_locale_all(nil)
    end

    def init_content_type #:nodoc:
      if headers["Content-Type"] and /javascript/ =~ headers["Content-Type"]
	headers["Content-Type"] = "text/javascript; charset=#{GetText.output_charset}"
      elsif ! headers["Content-Type"]
	headers["Content-Type"] = "#{@@gettext_content_type}; charset=#{GetText.output_charset}"
      end
    end

    def call_methods_around_init_gettext(ary)  #:nodoc:
      ary.each do |block|
	if block.kind_of? Symbol
	  send(block)
	else
	  block.call(self)
	end
      end
    end

    def init_gettext # :nodoc:
      cgi = nil
      if defined? request.cgi
        cgi = request.cgi
      end
      call_methods_around_init_gettext(@@before_init_gettext)
      init_gettext_main(cgi) if @@gettext_domainnames.size > 0
      call_methods_around_init_gettext(@@after_init_gettext)

      if ::RAILS_ENV == "development"
	@@before_init_gettext = []
	@@after_init_gettext = []
      end
    end

    # Append a block which is called before initializing gettext on the each WWW request.
    #
    # (e.g.)
    #   class ApplicationController < ActionController::Base
    #     before_init_gettext{|controller|
    #       cookies = controller.cookies
    #       if (cookies["lang"].nil? or cookies["lang"].empty?)
    #         GetText.locale = "zh_CN"
    #       else
    #         GetText.locale = cookies["lang"]
    #       end
    #     }
    #     init_gettext "myapp"
    #     # ...
    #   end
    @@before_init_gettext = []
    def self.before_init_gettext(*methods, &block)
      @@before_init_gettext += methods
      @@before_init_gettext << block if block_given? 
    end

    # Append a block which is called after initializing gettext on the each WWW request.
    #
    # The GetText.locale is set the locale which bound to the textdomains
    # when gettext is initialized.
    #
    # (e.g.)
    #   class ApplicationController < ActionController::Base
    #     after_init_gettext {|controller|
    #       L10nClass.new(GetText.locale)
    #     }
    #     init_gettext "foo"
    #     # ...
    #   end
    @@after_init_gettext = []
    def self.after_init_gettext(*methods, &block)
      @@after_init_gettext += methods
      @@after_init_gettext << block if block_given? 
    end
    
    # Bind a 'textdomain' to all of the controllers/views/models. Call this instead of GetText.bindtextdomain.
    # * textdomain: the textdomain
    # * options: options as a Hash.
    #   * :charset - the output charset. Default is "UTF-8"
    #   * :content_type - the content type. Default is "text/html"
    #   * :locale_path - the path to locale directory. Default is {RAILS_ROOT}/locale or {plugin root directory}/locale.
    #
    # locale is searched the order by params["lang"] > "lang" value of QUERY_STRING > 
    # "lang" value of Cookie > HTTP_ACCEPT_LANGUAGE value > Default locale(en). 
    # And the charset is set order by "the argument of bindtextdomain" > HTTP_ACCEPT_CHARSET > Default charset(UTF-8).
    #
    # Note: Don't use content_type argument(not in options). 
    # They are remained for backward compatibility.
    #
    # If you want to separate the textdomain each controllers, you need to call this function in the each controllers.
    #
    # app/controller/blog_controller.rb:
    #  require 'gettext/rails'
    #  
    #  class BlogController < ApplicationController
    #    init_gettext "blog"
    #      :
    #      :
    #    end
    def self.init_gettext(domainname, options = {}, content_type = "text/html")
      opt = {:charset => "UTF-8", :content_type => content_type}
      if options.kind_of? String
	# For backward compatibility
	opt.merge!(:charset => options, :content_type => content_type)
      else
	opt.merge!(options)
      end
      GetText.output_charset = opt[:charset]
      @@gettext_content_type = opt[:content_type]
      locale_path = opt[:locale_path]
      unless locale_path
	cal = caller[0]
	if cal =~ /app.controllers/
	  locale_path = File.join(cal.split(/app.controllers/)[0] + "locale")
	else
	  locale_path = File.join(RAILS_ROOT, "locale")
	end
      end

      unless @@gettext_domainnames.find{|i| i[0] == domainname}
	@@gettext_domainnames << [domainname, locale_path] 
      end

      bindtextdomain(domainname, {:path => locale_path})
      if defined? ActiveRecord::Base
	textdomain_to(ActiveRecord::Base, domainname) 
	textdomain_to(ActiveRecord::Validations, domainname)
      end
      textdomain_to(ActionView::Base, domainname) if defined? ActionView::Base
      textdomain_to(ApplicationHelper, domainname) if defined? ApplicationHelper
      textdomain_to(ActionMailer::Base, domainname) if defined? ActionMailer::Base
      textdomain_to(ActionView::Helpers, domainname) if defined? ActionView::Helpers
    end

    # Gets the textdomain name and path of this controller which is set 
    # with init_gettext. *(Since 1.8)*
    # 
    # * Returns: [[textdomainname1, path1], [textdomainname2, path2], ...]
    def self.textdomains
      @@gettext_domainnames
    end
  end

  class TestRequest < AbstractRequest  #:nodoc:
    class GetTextMockCGI < CGI #:nodoc:
      attr_accessor :stdinput, :stdoutput, :env_table
      
      def initialize(env, input=nil)
        self.env_table = env
        self.stdinput = StringIO.new(input || "")
        self.stdoutput = StringIO.new
        
        super()
      end
    end

    @cgi = nil
    def cgi
      unless @cgi
        @cgi = GetTextMockCGI.new("REQUEST_METHOD" => "GET",
                                  "QUERY_STRING"   => "",
                                  "REQUEST_URI"    => "/",
                                  "HTTP_HOST"      => "www.example.com",
                                  "SERVER_PORT"    => "80",
                                  "HTTPS"          => "off")
      end
      @cgi
    end
  end

end

module ActionView #:nodoc:
  class Base #:nodoc:
    # This provides to find localized template files such as foo_ja.html.erb, foo_ja_JP.html.erb
    # instead of foo.html.erb. If the file isn't found, foo.html.erb is used.
    def render_file_with_gettext(template_path, use_full_path = true, local_assigns = {})
      locale = GetText.locale
      begin
        [locale.to_general, locale.to_s, locale.language, Locale.default.language].uniq.each do |v|
          localized_path = "#{template_path}_#{v}"
          if (respond_to? :file_exists?) ? file_exists?(localized_path) : (finder.file_exists? localized_path)
            return render_file_without_gettext(localized_path, use_full_path, local_assigns)
          end
        end
      rescue Exception
        logger.debug($!)
        logger.debug($!.backtrace)
      end
      render_file_without_gettext(template_path, use_full_path, local_assigns)
    end
    alias_method_chain :render_file, :gettext
  end

if defined? TemplateFinder
  class TemplateFinder
    def pick_template_with_gettext(template_path, extension)
      locale = GetText.locale
      [locale.to_general, locale.to_s, locale.language, Locale.default.language].uniq.each do |v|
        file_name = "#{template_path}_#{v}.#{extension}"
        base_path = find_base_path_for(file_name)
        return "#{base_path}/#{file_name}" unless base_path.blank?
      end
      pick_template_without_gettext(template_path, extension)
    end
    alias_method_chain :pick_template, :gettext
  end
end

  module Helpers  #:nodoc:
    class FormBuilder
      include GetText
      
      def label_with_gettext(method, text = nil, options = {})
        text ||= s_("#{@object.class}|#{method.to_s.humanize}")
        @template.label(@object_name, method, text, options.merge(:object => @object))
      end
      alias_method_chain :label, :gettext
    end

    module ActiveRecordHelper #:nodoc: all
      module L10n
	# Separate namespace for textdomain
	include GetText

	bindtextdomain("rails")

	@error_message_title = Nn_("%{num} error prohibited this %{record} from being saved", 
				   "%{num} errors prohibited this %{record} from being saved")
	@error_message_explanation = Nn_("There was a problem with the following field:", 
					 "There were problems with the following fields:")

	module_function
	# call-seq:
	# set_error_message_title(msgs)
	#
	# Sets a your own title of error message dialog.
	# * msgs: [single_msg, plural_msg]. Usually you need to call this with Nn_().
	# * Returns: [single_msg, plural_msg]
	def set_error_message_title(msg, plural_msg = nil)
	  if msg.kind_of? Array
	    single_msg = msg[0]
	    plural_msg = msg[1]
	  else
	    single_msg = msg
	  end
	  @error_message_title = [single_msg, plural_msg]
	end
	
	# call-seq:
	# set_error_message_explanation(msg)
	#
	# Sets a your own explanation of the error message dialog.
	# * msg: [single_msg, plural_msg]. Usually you need to call this with Nn_().
	# * Returns: [single_msg, plural_msg]
	def set_error_message_explanation(msg, plural_msg = nil)
	  if msg.kind_of? Array
	    single_msg = msg[0]
	    plural_msg = msg[1]
	  else
	    single_msg = msg
	  end
	  @error_message_explanation = [single_msg, plural_msg]
	end

        # 
	def error_messages_for(instance, objects, object_names, count, options)
          record = ActiveRecord::Base.human_attribute_table_name_for_error(options[:object_name] || object_names[0].to_s)

          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key] 
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end

          if options[:message_title]
            header_message = instance.error_message(options[:message_title], count) % {:num => count, :record => record}
          else
            header_message = n_(@error_message_title, count) % {:num => count, :record => record}
          end
          if options[:message_explanation]
            message_explanation = instance.error_message(options[:message_explanation], count) % {:num => count}
          else
            message_explanation = n_(@error_message_explanation, count) % {:num => count}
          end

          error_messages = objects.map {|object| object.errors.full_messages.map {|msg| instance.content_tag(:li, msg) } }
            
          instance.content_tag(:div,
                            instance.content_tag(options[:header_tag] || :h2, header_message) <<
                            instance.content_tag(:p, message_explanation) <<
                            instance.content_tag(:ul, error_messages),
                            html
                            )
	end
      end

      def error_message(msg, count) #:nodoc:
        ngettext(msg, count)
      end

      alias error_messages_for_without_localize error_messages_for #:nodoc:

      # error_messages_for overrides original method with localization.
      # And also it extends to be able to replace the title/explanation of the header of the error dialog. (Since 1.90)
      # If you want to override these messages in the whole application, 
      #    use ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_(title|explanation) instead.
      # * :message_title - the title of message. Use Nn_() to path the strings for singular/plural.
      #                       e.g. Nn_("%{num} error prohibited this %{record} from being saved", 
      # 			       "%{num} errors prohibited this %{record} from being saved")
      # * :message_explanation - the explanation of message
      #                       e.g. Nn_("There was a problem with the following field:", 
      #                                "There were %{num} problems with the following fields:")
      def error_messages_for(*params)
        options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
        objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        object_names = params.dup
        count   = objects.inject(0) {|sum, object| sum + object.errors.count }
        if count.zero?
          ''
        else
          L10n.error_messages_for(self, objects, object_names, count, options)
        end
      end
    end

    module DateHelper #:nodoc: all
      include GetText
      alias distance_of_time_in_words_without_locale distance_of_time_in_words #:nodoc:

      # This is FAKE constant. The messages are found by rgettext as the msgid. 
      MESSAGESS = [N_('less than 5 seconds'), N_('less than 10 seconds'), N_('less than 20 seconds'),
                   N_('half a minute'), N_('less than a minute'), N_('about 1 month'), 
                   N_('about 1 year')]
      NMINUTES = [/^(\d+) minutes?$/, Nn_('1 minute', '%{num} minutes')]
      NHOURS   = [/^about (\d+) hours?$/, Nn_('about 1 hour', 'about %{num} hours')]
      NDAYS    = [/^(\d+) days?$/, Nn_('1 day', '%{num} days')]
      NMONTHS  = [/^(\d+) months?$/, Nn_('1 month', '%{num} months')]
      NYEARS  = [/^over (\d+) years?$/, Nn_('over 1 year', 'over %{num} years')]

      def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
	textdomain("rails")

	msg = distance_of_time_in_words_without_locale(from_time, to_time, include_seconds)
	match = false
	[NMINUTES, NHOURS, NDAYS, NMONTHS, NYEARS].each do |regexp, nn|
	  if regexp =~ msg
	    match = true
	    msg = n_(nn, $1.to_i) % {:num => $1}
	    break
	  end
	end
	match ? msg : _(msg)
      end
    end
  end
end

if defined? ActionMailer
  module ActionMailer #:nodoc:
    class Base #:nodoc:
      helper GetText::Rails
      include GetText::Rails 
      extend GetText::Rails
      
      alias :create_without_gettext! :create! #:nodoc:
      
      def base64(text, charset="iso-2022-jp", convert=true)
	if convert
	  if charset == "iso-2022-jp"
	    text = NKF.nkf('-j -m0', text)
        end
	end
	text = TMail::Base64.folding_encode(text)
	"=?#{charset}?B?#{text}?="
      end
      
      def create!(*arg) #:nodoc:
	create_without_gettext!(*arg)
	if Locale.get.language == "ja"
	  require 'nkf'
	  @mail.subject = base64(@mail.subject)
	  part = @mail.parts.empty? ? @mail : @mail.parts.first
	  if part.content_type == 'text/plain'
	    part.charset = 'iso-2022-jp'
	    part.body = NKF.nkf('-j', part.body)
	  end
	end
        @mail
      end
    end
  end
end

module ActionController #:nodoc: all
  module Caching
    module Fragments
      def fragment_cache_key_with_gettext(name) 
        ret = fragment_cache_key_without_gettext(name)
        if ret.is_a? String
          ret.gsub(/:/, ".") << "_#{normalized_locale}"
        else
          ret
        end
      end
      alias_method_chain :fragment_cache_key, :gettext

      def expire_fragment_with_gettext(name, options = nil)
        return unless perform_caching

        fc_store = (respond_to? :cache_store) ? cache_store : fragment_cache_store
        key = name.is_a?(Regexp) ? name : fragment_cache_key_without_gettext(name)
        if key.is_a?(Regexp)
          self.class.benchmark "Expired fragments matching: #{key.source}" do
            fc_store.delete_matched(key, options)
          end
        else
          key = key.gsub(/:/, ".")
          self.class.benchmark "Expired fragment: #{key}, lang = #{available_locales.inspect}" do
            available_locales.each do |lang|
              fc_store.delete("#{key}_#{lang}", options)
            end
          end
        end
      end
      alias_method_chain :expire_fragment, :gettext
    end
  end
end

begin
  Rails::Info.property("GetText version") do 
    GetText::VERSION 
  end
rescue Exception
  $stderr.puts "GetText: #{GetText::VERSION} Rails::Info is not found." if $DEBUG
end


if ::RAILS_ENV == "development"
  GetText.cached = false
end

require 'gettext/active_record'
