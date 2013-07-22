module LineModules

  module GroupedAndMergedLines

    def grouped_and_merged_lines
        grouped_and_merged_lines = lines.group_by{|l| {start_date: l.start_date, inventory_pool: l.inventory_pool}}
        grouped_and_merged_lines.each_pair do |k,lines|
          grouped_and_merged_lines[k] = begin
            hash = lines.sort_by{|l| l.model}.group_by{|l| {end_date: l.end_date, model: l.model}}
            hash.values.map {|array| 
              h = {
                line_ids: array.map(&:id),
                quantity: array.sum(&:quantity),
                model: array.first.model,
                start_date: array.first.start_date,
                end_date: array.first.end_date
              }
              h[:available?] = array.all? {|l| l.available? } if respond_to? :timeout? and timeout?
              h
            }
          end
        end
      end

  end
end

  