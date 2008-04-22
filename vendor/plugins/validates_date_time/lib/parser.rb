module ActiveRecord
  module ConnectionAdapters
    class Column
      class << self
        def string_to_date(value)
          return if value.blank?
          return value if value.is_a?(Date)
          return value.to_date if value.is_a?(Time) || value.is_a?(DateTime)
          
          year, month, day = case value.strip
            # 22/1/06, 22\1\06 or 22.1.06
            when /\A(\d{1,2})[\\\/\.-](\d{1,2})[\\\/\.-](\d{2}|\d{4})\Z/
              ValidatesDateTime.us_date_format ? [$3, $1, $2] : [$3, $2, $1]
            # 22 Feb 06 or 1 jun 2001
            when /\A(\d{1,2}) (\w{3,9}) (\d{2}|\d{4})\Z/
              [$3, $2, $1]
            # July 1 2005
            when /\A(\w{3,9}) (\d{1,2})\,? (\d{2}|\d{4})\Z/
              [$3, $1, $2]
            # 2006-01-01
            when /\A(\d{4})-(\d{2})-(\d{2})\Z/
              [$1, $2, $3]
            # 2006-01-01T10:10:10+13:00
            when /\A(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\Z/
              [$1, $2, $3]
            # Not a valid date string
            else
              return nil
          end
          
          Date.new(unambiguous_year(year), month_index(month), day.to_i) rescue nil
        end
        
        def string_to_dummy_time(value)
          return if value.blank?
          return value if value.is_a?(Time) || value.is_a?(DateTime)
          return value.to_time(ActiveRecord::Base.default_timezone) if value.is_a?(Date)
          
          hour, minute, second, microsecond = case value.strip
            # 12 hours with minute and second
            when /\A(\d{1,2})[\. :](\d{2})[\. :](\d{2})\s?(am|pm)\Z/i
              [full_hour($1, $4), $2, $3]
            # 12 hour with minute: 7.30pm, 11:20am, 2 20PM
            when /\A(\d{1,2})[\. :](\d{2})\s?(am|pm)\Z/i
              [full_hour($1, $3), $2]
            # 12 hour without minute: 2pm, 11Am, 7 pm
            when /\A(\d{1,2})\s?(am|pm)\Z/i
              [full_hour($1, $2)]
            # 24 hour: 22:30, 03.10, 12 30
            when /\A(\d{2})[\. :](\d{2})([\. :](\d{2})(\.(\d{1,6}))?)?\Z/
              [$1, $2, $4, $6]
            # 2006-01-01T10:10:10+13:00
            when /\A(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\Z/
              [$4, $5, $6]
            # Not a valid time string
            else
              return nil
          end
          
          Time.send(ActiveRecord::Base.default_timezone, 2000, 1, 1, hour.to_i, minute.to_i, second.to_i, microsecond.to_i) rescue nil
        end
        
        def string_to_time(value)
          return if value.blank?
          return value if value.is_a?(Time) || value.is_a?(DateTime)
          return value.to_time(ActiveRecord::Base.default_timezone) if value.is_a?(Date)
          
          value = value.strip
          
          if value =~ /\A(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\Z/
            time_array = [$1, $2, $3, $4, $5, $6].map!(&:to_i)
          else
            # The basic approach is to attempt to parse a date from the front of the string, splitting on spaces.
            # Once a date has been parsed, a time is extracted from the rest of the string.
            split_index = date = nil
            loop do
              split_index = value.index(' ', split_index ? split_index + 1 : 0)
              
              if split_index.nil? or date = string_to_date(value.first(split_index))
                break
              end
            end
            
            return if date.nil?
            
            time = string_to_dummy_time(value.last(value.size - split_index))
            return if time.nil?
            
            time_array = [date.year, date.month, date.day, time.hour, time.min, time.sec, time.usec]
          end
          
          # From schema_definitions.rb
          begin
            Time.send(ActiveRecord::Base.default_timezone, *time_array)
          rescue
            zone_offset = if Base.default_timezone == :local then DateTime.now.offset else 0 end
            # Append zero calendar reform start to account for dates skipped by calendar reform
            DateTime.new(*time_array[0..5] << zone_offset << 0) rescue nil
          end
        end
        
        def full_hour(hour, meridian)
          hour = hour.to_i
          if meridian.strip.downcase == 'am'
            hour == 12 ? 0 : hour
          else
            hour == 12 ? hour : hour + 12
          end
        end
        
        def month_index(month)
          return month.to_i if month.to_i.nonzero?
          Date::ABBR_MONTHNAMES.index(month.capitalize) || Date::MONTHNAMES.index(month.capitalize)
        end
        
        # Extract a 4-digit year from a 2-digit year.
        # If the number is less than 20, assume year 20#{number}
        # otherwise use 19#{number}. Ignore if already 4 digits.
        #
        # Eg:
        #    10 => 2010, 60 => 1960, 00 => 2000, 1963 => 1963
        def unambiguous_year(year)
          year = "#{year.to_i < 20 ? '20' : '19'}#{year}" if year.length == 2
          year.to_i
        end
      end
    end
  end
end
