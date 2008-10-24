=begin
  locale/object.rb - Locale::Object

  Copyright (C) 2006,2007  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: object.rb,v 1.4 2008/08/19 16:22:34 mutoh Exp $
=end


module Locale
  class Object
    attr_reader :language, :country, :charset, :script, :variant, :modifier, :orig_str

    # Set the language. e.g.) ja, en, fr, ...
    def language=(val)
      @language = val
      clear
    end

    # Set the country.  e.g.) JP, US, FR, ...
    def country=(val)
      @country = val
      clear
    end

    # Set the charset.   e.g.) UTF-8, EUC-JP, Shift_JIS
    def charset=(val)
      @charset = val
      clear
    end

    # Set the script.   e.g.) Latn
    def script=(val)
      @script = val
      clear
    end

    # Set the variant.   e.g.) Hant
    def variant=(val)
      @variant = val
      clear
    end

    # Set the modifier.  e.g.) curreny=DDM
    def modifier=(val)
      @modifier = val
      clear
    end

    # A fallback locale. With GetText, you don't need to set English(en,C,POSIX) 
    # by yourself because English is used as the last fallback locale anytime.
    attr_accessor :fallback

    # Parse POSIX or RFC 3066 style locale name to Array.
    #
    # * locale_name: locale name as String 
    #   
    #   * Basic POSIX format: <language>_<COUNTRY>.<charset>@<modifier>
    #     * Both of POSIX and C are converted to "en".
    #   * Basic RFC3066 format: <language>-<COUNTRY>
    #   * Win32 format: <language>-<COUNTRY>-<Script>_<sort order>
    #   * CLDR format: <language>_<Script>_<COUNTRY>_<variant>@<modifier>
    #   * Some broken format: <language>_<country>_<script>  # Don't use this.
    #   * The max locale format is below:     
    #     * <language>-<COUNTRY>-<Script>_<sort order>.<charset>@<modifier>
    #     * format: <language>_<Script>_<COUNTRY>_<variant>@<modifier>
    #       * both of '-' and '_' are separators.
    #       * each elements are omittable.
    #   
    #   (e.g.) uz-UZ-Latn, ja_JP.eucJP, wa_BE.iso885915@euro
    # * Returns: [language, country, charset, script, modifier]
    #   * language: a lowercase ISO 639(or 639-2/T) language code.
    #   * country: an uppercase ISO 3166-1 country/region identifier.
    #   * charset: charset(codeset) (no standard)
    #   * script: an initial-uppercase ISO 15924 script code. 
    #   * variant: variant value in CLDR or sort order in Win32.
    #   * modifier: (no standard)
    #
    #  (e.g.)
    #  "ja_JP.eucJP" => ["ja", "JP", "eucJP", nil, nil]
    #  "ja-jp.utf-8" => ["ja", "JP", "utf-8", nil, nil]
    #  "ja-jp" => ["ja", "JP", nil, nil, nil]
    #  "ja" => ["ja", nil, nil, nil, nil]
    #  "uz@Latn" => ["uz", nil, nil, nil, "Latn"]
    #  "uz-UZ-Latn" => ["uz", "UZ", nil, "Latn", nil]
    #  "uz_UZ_Latn" => ["uz", "UZ", nil, "Latn", nil]
    #  "wa_BE.iso885915@euro" => ["wa", "BE", "iso885915", nil, "euro"]
    #  "C" => ["en", nil, nil, nil, nil]
    #  "POSIX" => ["en", nil, nil, nil, nil]
    #  "zh_Hant" => ["zh", nil, nil, "Hant", nil]
    #  "zh_Hant_HK" => ["zh", "HK", nil, "Hant", nil]
    #  "de_DE@collation=phonebook,currency=DDM" => ["de", "DE", nil, nil, "collation=phonebook,currency=DDM"]

    def self.parse(locale_name)
      if locale_name.nil? || locale_name.empty?
        return ["en", nil, nil, nil, nil, nil]
      else
        lang_charset, modifier = locale_name.split(/@/)
        lang, charset = lang_charset.split(/\./)
        language, country, script, variant = lang.gsub(/_/, "-").split('-')
        language = language ? language.downcase : nil
        language = "en" if language == "c" || language == "posix"
      end
      if country
	if country =~ /\A[A-Z][a-z]+\Z/  #Latn => script
	  tmp = script
	  script = country
	  if tmp =~ /\A[A-Z]+\Z/ #US => country
	    country = tmp
	  else
	    country = nil
	    variant = tmp
	  end
	else
	  country = country.upcase
	  if script !~ /\A[A-Z][a-z]+\Z/ #Latn => script
	    variant = script
	    script = nil
	  end
	end
      end
      [language, country, charset, script, variant, modifier]
    end

    # Initialize Locale::Object.
    # * language_or_locale_name: language(ISO 639) or POSIX or RFC3066 style locale name
    # * country: an uppercase ISO 3166-1 country/region identifier, or nil
    # * charset: charset(codeset) (no standard), or nil
    #
    #  Locale::Object.new("ja", "JP", "eucJP")
    #   -> language = "ja", country = "JP", charset = "eucJP".
    #  Locale::Object.new("ja", "JP")
    #   -> language = "ja", country = "JP", charset = nil.
    #  Locale::Object.new("ja_JP.eucJP")
    #   -> language = "ja", country = "JP", charset = "eucJP".
    #  Locale::Object.new("ja_JP.eucJP", nil, "UTF-8")
    #   -> language = "ja", country = "JP", charset = "UTF-8".
    #  Locale::Object.new("en-US", "CA")
    #   -> language = "en", country = "CA", charset = nil.
    #  Locale::Object.new("uz-uz-latn")
    #   -> language = "uz", country = "UZ", charset = nil, script = "Latn"
    #  Locale::Object.new("uz_UZ_Latn")
    #   -> language = "uz", country = "UZ", charset = nil, script = "Latn"
    #  Locale::Object.new("we_BE.iso885915@euro")
    #   -> language = "we", country = "BE", charset = "iso885915", modifier = "euroo".
    #  Locale::Object.new("C")
    #   -> language = "en", country = nil, charset = nil.
    #  Locale::Object.new("POSIX")
    #   -> language = "en", country = nil, charset = nil.
    def initialize(language_or_locale_name, country = nil, charset = nil)
      @orig_str = language_or_locale_name
      @language, @country, @charset, @script, @variant, @modifier = 
	self.class.parse(language_or_locale_name)
      @country = country if country
      @charset = charset if charset
      @fallback = nil
      clear
    end

    def clear
      @posix = nil
      @iso3066 = nil
      @win = nil
      @general = nil
      @hash = "#{self.class}:#{to_general}.#{@charset}@#{@modifier}".hash
    end
    
    # Returns the locale as POSIX format(but charset is ignored). (e.g.) "ja_JP"
    def to_posix
      return @posix if @posix
      @posix = @language.dup

      @posix << "_#{@country}" if @country
      @posix
    end

    # Returns the locale as ISO3066 format. (e.g.) "ja-JP"
    def to_iso3066
      return @iso3066 if @iso3066

      @iso3066 = @language.dup
      @iso3066 << "-#{@country}" if @country
      @iso3066
    end

    # Returns the locale as Win32 format. (e.g.) "az-AZ-Latn".
    # 
    # This is used to find the charset from locale table.
    def to_win
      return @win if @win

      @win = @language.dup
      @win << "-#{@country}" if @country
      @win << "-#{@script}" if @script
      @win
    end

    # Returns the locale as 'ruby' general format. (e.g.) "az_AZ_Latn"
    def to_general
      return @general if @general
 
      @general = @language.dup
      @general << "_#{@country}" if @country
      @general << "_#{@script}" if @script 
      @general
    end

    # Gets the locale informations as an Array.
    # * Returns [language, country, charset, script, variant, modifier]
    #   * language: a lowercase ISO 639(or 639-2/T) language code.
    #   * country: an uppercase ISO 3166-1 country/region identifier.
    #   * charset: charset(codeset) (no standard)
    #   * script: an initial-uppercase ISO 15924 script code. 
    #   * variant: variant value in CLDR or sort order in Win32.
    #   * modifier: (no standard)
    def to_a
      [@language, @country, @charset, @script, @variant, @modifier]
    end

    def ==(other)  #:nodoc:
      other != nil and @hash == other.hash
    end

    def eql?(other) #:nodoc:
      self.==(other)
    end

    def hash #:nodoc:
      @hash
    end
    alias :to_s :to_posix
    alias :to_str :to_posix
  end
end
