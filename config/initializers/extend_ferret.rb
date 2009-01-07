class Array
      
  # TODO 06** optimize scoping directly to sql
  # Forward search query to Ferret search engine
  def search(q, options = {}, find_options = {})
    classes = self.collect(&:class).uniq
    c = classes.shift
    options[:multi] = classes unless classes.empty? # TODO 06** where is it used?
    
#    ids = self.collect{|x| "id:#{x.id}"}.join(" OR ")
#    query = "(#{q}) AND (#{ids})"
#    c.find_by_contents(query, options, find_options)

    find_options[:conditions] = ["#{c.table_name}.#{c.primary_key} IN (?)", self]
    c.find_by_contents(q, options, find_options)
  end

end

##########################################################

class Class
      
  # Forward search query to Ferret search engine
  def search(q, options = {}, find_options = {})
    c = self 
    c.find_by_contents(q, options, find_options)
  end

end
