class Template < ModelGroup

  has_many :line_groups

  acts_as_ferret :fields => [ :name ], :store_class_name => true

  # TODO merge model_links with same models and sum quantities

  
  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil)
    lg = LineGroup.create(:model_group => self)
    
    model_links.each do |ml|
      document.add_line(ml.quantity, ml.model, user_id, start_date, end_date, lg)
    end
  end  

  def total_quantity
    total = 0
    model_links.each { |ml| total += ml.quantity }
    total
  end
  
  
end
