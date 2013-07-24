module LineModules

  module GroupedAndMergedLines

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def grouped_and_merged_lines_for_collection(date = :start_date, collection)
        h = {}
          collection.map{|element| element.grouped_and_merged_lines(date)}.each do |element|
            element.each do |k,v|
              if h[k]
                v.each do |entry|
                  h[k].push entry
                end
              else
                h[k] = v
              end
            end
          end
        h
      end
    end

    def grouped_and_merged_lines(date = :start_date)
      grouped_and_merged_lines = lines.group_by do |l| 
        case date
          when :start_date
            {start_date: l.start_date, inventory_pool: l.inventory_pool} 
          when :end_date
            {end_date: l.end_date, inventory_pool: l.inventory_pool}
        end
      end
      grouped_and_merged_lines.each_pair do |k,lines|
        grouped_and_merged_lines[k] = begin
          hash = lines.sort_by{|l| l.model.name}.group_by do |l| 
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
            h[:available?] = array.all? {|l| l.available? } if respond_to? :timeout? and timeout?
            h
          }
        end
      end
    end
  end
end