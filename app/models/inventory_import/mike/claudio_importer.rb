class ClaudioImporter
  
  def start(filename)
    line_count = 0
    File.open(filename) do |file|
      file.each_line do |line|
        line_count = line_count + 1
        if line_count > 1
          field = line.split(";")
          
          i = Item.find_by_inventory_code field[0]
          if i
            add_to(i.model, [field[4], field[5], field[6]])
          else
            puts "Item not found #{field[0]}"  
          end
        end
        #puts "."
      end  
    end
  end
  
  def add_to(model, cats)
#    model.categories.clear
#    model.save
    if cats
      cats.each do |cat|
     
        if cat != nil and not "".eql?(cat.strip)
          c = Category.find_by_name(cat.strip)
          if c
            c.models << model unless c.models.include?(model)
           # puts "done: #{cat}"
          else
            puts "#{cat} not found"
          end
        end
      end
      model.save
    end
  end
end

#script/runner app/models/inventory_import/mike/claudio_importer.rb app/models/inventory_import/mike/categories.csv

ClaudioImporter.new.start(ARGV[0])