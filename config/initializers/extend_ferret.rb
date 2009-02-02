class Array
      
  # TODO 06** optimize scoping directly to sql
  # Forward search query to Ferret search engine
  def search(q, options = {}, find_options = {})
    q = "*" if q.blank? # TODO 21** avoid using ferret (use directly paginate instead)
    unless q.blank? or self.empty?
      classes = self.collect(&:class).uniq
      c = classes.shift
      #options[:multi] = classes unless classes.empty? # TODO 06** where is it used?
      
      #ids = self.collect{|x| "id:#{x.id}"}.join(" OR ")
      #q = "(#{q}) AND (#{ids})"
  
      #temp# c.find_id_by_contents(q).last.collect {|r| r[:id] }
  
      find_options[:conditions] = ["#{c.table_name}.#{c.primary_key} IN (?)", self]
      c.find_by_contents(q, options, find_options)
    else
      self.paginate options.merge(find_options)      
    end
  end

end

##########################################################

class Class
      
  # Forward search query to Ferret search engine
  def search(q, options = {}, find_options = {})
    unless q.blank?
      self.find_by_contents(q, options, find_options)
    else
      self.paginate options.merge(find_options)      
    end
  end

end
