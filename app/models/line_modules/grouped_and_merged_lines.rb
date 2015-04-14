module LineModules

  module GroupedAndMergedLines

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def grouped_and_merged_lines(lines, date = :start_date)
        gmlines = lines.group_by do |l|
          case date
            when :start_date
              {start_date: l.start_date, inventory_pool: l.inventory_pool}
            when :end_date
              {end_date: l.end_date, inventory_pool: l.inventory_pool}
          end
        end.sort_by {|h| [h.first[date], h.first[:inventory_pool].name]}
        gmlines = Hash[gmlines]
        gmlines.each_pair do |k,v|
          gmlines[k] = begin
            hash = v.sort_by{|l| l.model.name}.group_by do |l|
              case date
                when :start_date
                  {end_date: l.end_date, model: l.model}
                when :end_date
                  {start_date: l.start_date, model: l.model}
              end
            end
            hash.values.map {|array|
              h = {
                  line_ids: array.map(&:id),
                  quantity: array.sum(&:quantity),
                  model: array.first.model,
                  start_date: array.first.start_date,
                  end_date: array.first.end_date
              }
              h[:available?] = array.all? {|l| l.available? } if array.all? {|l| l.status == :unsubmitted } and array.any? {|l| l.user.timeout? }
              h
            }
          end
        end
      end

    end

  end
end
