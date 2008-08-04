=begin
  gettext/active_record.rb - GetText for ActiveRecord

  Copyright (C) 2006-2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: active_record.rb,v 1.25 2008/07/24 17:17:48 mutoh Exp $
=end
require 'gettext'
require 'active_record'
require 'gettext/rails_compat'

module ActiveRecord #:nodoc:
  class Migration
    extend GetText
    include GetText
  end

  class RecordInvalid < ActiveRecordError #:nodoc:
    attr_reader :record
    include GetText
    bindtextdomain("rails")

    def initialize(record)
      @record = record
      super(_("Validation failed: %{error_messages}") % 
            {:error_messages => @record.errors.full_messages.join(", ")})
    end
  end

  
  module ConnectionAdapters #:nodoc:
    # An abstract definition of a column in a table.
    class Column
      attr_accessor :table_class
      alias :human_name_witout_localized :human_name 

      def human_name_with_gettext
        if table_class
          table_class.human_attribute_name(@name)
        else
          @name.humanize
        end
      end
      alias_method_chain :human_name, :gettext
    end
  end

  module Validations # :nodoc:
    class << self
      def real_included(base)
        base.extend ClassMethods
        base.class_eval{
          include GetText
          def gettext(str)  #:nodoc:
            _(str)
          end
          class << self
            def human_attribute_name_with_gettext(attribute_key_name) #:nodoc:
              s_("#{self}|#{attribute_key_name.humanize}")
            end
            alias_method_chain :human_attribute_name, :gettext
            def human_attribute_table_name_for_error(table_name) #:nodoc:
              _(table_name.gsub(/_/, " "))
            end
          end
        }
      end
    end

    if respond_to? :included
      class << self
        def included_with_gettext(base) # :nodoc:
          unless base <= ActiveRecord::Base
            included_without_gettext(base)
          end
          real_included(base)
        end
        alias_method_chain :included, :gettext
      end
    else
      class << self
        # Since rails-1.2.0.
        def append_features_with_gettext(base) # :nodoc:
          unless base <= ActiveRecord::Base
            append_features_without_gettext(base)
          end
          real_included(base)
        end
        alias_method_chain :append_features, :gettext
      end
    end

    module ClassMethods #:nodoc:
      @@custom_error_messages_d = {}
      # Very ugly but...
      def validates_length_of_with_gettext(*attrs)  #:nodoc:
	if attrs.last.is_a?(Hash)
          [:message, :too_long, :too_short, :wrong_length].each do |msg_sym|
            msg = attrs.last[msg_sym]
            @@custom_error_messages_d[msg] = /\A#{Regexp.escape(msg).sub(/%d/, '(\d+)')}\Z/ if msg
          end
	end
	validates_size_of(*attrs)
      end
      alias_method_chain :validates_length_of, :gettext

      def _validates_parse_custom_messages(*attrs) #:nodoc:
	if attrs.last.is_a?(Hash) and attrs.last[:message]
          msg = attrs.last[:message]
          key = msg.dup
          msg.sub!(/%\{val\}/, '%s')
          @@custom_error_messages_d[key] = /\A#{Regexp.escape(msg).sub('%s', '(.*)')}\Z/
	end
        attrs
      end
      
      def validates_format_of_with_gettext(*attrs)  #:nodoc:
        attrs = _validates_parse_custom_messages(*attrs)
	validates_format_of_without_gettext(*attrs)
      end
      alias_method_chain :validates_format_of, :gettext

      def validates_inclusion_of_with_gettext(*attrs)  #:nodoc:
        attrs = _validates_parse_custom_messages(*attrs)
	validates_inclusion_of_without_gettext(*attrs)
      end
      alias_method_chain :validates_inclusion_of, :gettext

      def validates_exclusion_of_with_gettext(*attrs)  #:nodoc:
        attrs = _validates_parse_custom_messages(*attrs)
	validates_exclusion_of_without_gettext(*attrs)
      end
      alias_method_chain :validates_exclusion_of, :gettext

      def custom_error_messages_d  #:nodoc:
	@@custom_error_messages_d
      end
    end
    def custom_error_messages_d  #:nodoc:
      self.class.custom_error_messages_d
    end
  end
  
  class Base
    include GetText
    include Validations

    @@gettext_untranslate = Hash.new(false)
    @@gettext_untranslate_columns = {}

    class << self
      # Untranslate all of the tablename/fieldnames in this model class.
      def untranslate_all
        @@gettext_untranslate[self] = true
      end

      # Returns true if "untranslate_all" is called. Otherwise false.
      def untranslate_all?
        @@gettext_untranslate[self]
      end

      # Sets the untranslate columns.
      # (e.g.) untranslate :foo, :bar, :baz
      def untranslate(*w)
        ary = @@gettext_untranslate_columns[self] || []
        ary += w.collect{|v| v.to_s}
        @@gettext_untranslate_columns[self] = ary
      end
      
      # Returns true if the column is set "untranslate".
      # (e.g.) untranslate? :foo
      def untranslate?(columnname)
        ary = @@gettext_untranslate_columns[self] || []
        ary.include?(columnname)
      end

      def untranslate_data #:nodoc:
        [@@gettext_untranslate[self], @@gettext_untranslate_columns[self] || []]
      end

      def columns_with_gettext
        unless defined? @columns
          @columns = nil 
        end
        unless @columns
          @columns = columns_without_gettext
          @columns.each {|column| 
            column.table_class = self
          }
        end
        @columns
      end
      alias_method_chain :columns, :gettext
    
      # call-seq:
      # set_error_message_title(msg)
      #
      # ((*Deprecated*)) 
      # Use ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_title
      # instead.
      #
      # Sets a your own title of error message dialog.
      # * msg: [single_msg, plural_msg]. Usually you need to call this with Nn_().
      # * Returns: [single_msg, plural_msg]
      def set_error_message_title(msg, plural_msg = nil)
        ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_title(msg, plural_msg)
      end
      
      # call-seq:
      # set_error_message_explanation(msg)
      #
      # ((*Deprecated*)) 
      # Use ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_explanation
      # instead.
      #
      # Sets a your own explanation of the error message dialog.
      # * msg: [single_msg, plural_msg]. Usually you need to call this with Nn_().
      # * Returns: [single_msg, plural_msg]
      def set_error_message_explanation(msg, plural_msg = nil)
        ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_explanation(msg, plural_msg)
      end
    end
  end

  # activerecord-1.14.3/lib/active_record/validations.rb
  class Errors #:nodoc:
    include GetText

    def initialize_with_gettext(base) # :nodoc:
      initialize_without_gettext(base)
      bindtextdomain("rails")
    end
    alias_method_chain :initialize, :gettext

    def @@default_error_messages.[]=(id, msg) #:nodoc:
      @@default_error_messages.update({id => msg})
      if [:message, :too_long, :too_short, :wrong_length].include?(id)
	@@default_error_messages_d[msg] = /\A#{Regexp.escape(msg).sub(/%d/, '(\d+)')}\Z/ 
      end
    end    

    # You need to define this here, because this values will be updated by application.
    default_error_messages.update(
				  :inclusion => N_("%{fn} is not included in the list"),
				  :exclusion => N_("%{fn} is reserved"),
				  :invalid => N_("%{fn} is invalid"),
				  :confirmation => N_("%{fn} doesn't match confirmation"),
				  :accepted  => N_("%{fn} must be accepted"),
				  :empty => N_("%{fn} can't be empty"),
				  :blank => N_("%{fn} can't be blank"),
				  :too_long => N_("%{fn} is too long (maximum is %d characters)"),  
				  :too_short => N_("%{fn} is too short (minimum is %d characters)"), 
				  :wrong_length => N_("%{fn} is the wrong length (should be %d characters)"),
				  :taken => N_("%{fn} has already been taken"),
				  :not_a_number => N_("%{fn} is not a number"),
                                  :greater_than => N_("%{fn} must be greater than %d"),
                                  :greater_than_or_equal_to => N_("%{fn} must be greater than or equal to %d"),
                                  :equal_to => N_("%{fn} must be equal to %d"),
                                  :less_than => N_("%{fn} must be less than %d"),
                                  :less_than_or_equal_to => N_("%{fn} must be less than or equal to %d"),
                                  :odd => N_("%{fn} must be odd"),
                                  :even => N_("%{fn} must be even")
				  )
    @@default_error_messages_d = {
      default_error_messages[:too_long] => /#{Regexp.escape(default_error_messages[:too_long]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:too_short] => /#{Regexp.escape(default_error_messages[:too_short]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:wrong_length] => /#{Regexp.escape(default_error_messages[:wrong_length]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:greater_than] => /#{Regexp.escape(default_error_messages[:greater_than]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:greater_than_or_equal_to] => /#{Regexp.escape(default_error_messages[:greater_than_or_equal_to]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:equal_to] => /#{Regexp.escape(default_error_messages[:equal_to]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:less_than] => /#{Regexp.escape(default_error_messages[:less_than]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:less_than_or_equal_to] => /#{Regexp.escape(default_error_messages[:less_than_or_equal_to]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:odd] => /#{Regexp.escape(default_error_messages[:odd]).sub(/%d/, '(\d+)')}/,
      default_error_messages[:even] => /#{Regexp.escape(default_error_messages[:even]).sub(/%d/, '(\d+)')}/,
    }
    cattr_accessor :default_error_messages_d

    def localize_error_message(attr, msg, append_field) # :nodoc:
      custom_msg = nil
      #Ugly but... :-<
      @@default_error_messages_d.dup.merge(@base.custom_error_messages_d).each do |key, regexp|
        if regexp =~ msg
          custom_msg = @base.gettext(key)
          custom_msg = _(msg) if custom_msg == msg 
          custom_msg = _(custom_msg) % $1
          custom_msg = _(custom_msg) % {:val => $1}
          break
        end
      end

      unless custom_msg
        custom_msg = @base.gettext(msg)
        custom_msg = _(msg) if custom_msg == msg 
      end

      if attr == "base"
        full_message = custom_msg
      elsif /%\{fn\}/ =~ custom_msg
        full_message = custom_msg % {:fn => @base.class.human_attribute_name(attr)}
      elsif append_field
        full_message = @base.class.human_attribute_name(attr) + " " + custom_msg
      else
        full_message = custom_msg
      end
      full_message
    end

    def localize_error_messages(append_field = true) # :nodoc:
      # e.g.) foo field: "%{fn} foo" => "Foo foo", "foo" => "Foo foo". 
      errors = {}
      each {|attr, msg|
        next if msg.nil?
        errors[attr] ||= []
        errors[attr] << localize_error_message(attr, msg, append_field)
      }
      errors
    end

    # Returns error messages.
    # * Returns nil, if no errors are associated with the specified attribute.
    # * Returns the error message, if one error is associated with the specified attribute.
    # * Returns an array of error messages, if more than one error is associated with the specified attribute.
    # And for GetText,
    # * If the error messages include %{fn}, it returns formatted text such as "foo %{fn}" => "foo Field"
    # * else, the error messages are prepended the field name such as "foo" => "foo" (Same as default behavior).
    # Note that this behaviour is different from full_messages.
    def on_with_gettext(attribute)
      # e.g.) foo field: "%{fn} foo" => "Foo foo", "foo" => "foo". 
      errors = localize_error_messages(false)[attribute.to_s]
      return nil if errors.nil?
      errors.size == 1 ? errors.first : errors
    end
    alias_method_chain :on, :gettext 
    alias :[] :on

    # Returns all the full error messages in an array.
    # * If the error messages include %{fn}, it returns formatted text such as "foo %{fn}" => "foo Field"
    # * else, the error messages are prepended the field name such as "foo" => "Field foo" (Same as default behavior).
    # As L10n, first one is recommanded because the order of subject,verb and others are not same in languages.
    def full_messages_with_gettext
      full_messages = []
      errors = localize_error_messages
      errors.each_key do |attr|
        errors[attr].each do |msg|
	  next if msg.nil?
	  full_messages << msg
	end
      end
      full_messages
    end
    alias_method_chain :full_messages, :gettext 
  end
end

