class Template < ModelGroup

  has_many :line_groups
  
  
  def add_to_document(document, user_id)
    
    lg = LineGroup.create(:model_group => self)
    
    model_links.each do |ml|
      document.add_line(ml.quantity, ml.model, user_id, nil, nil, lg)
    end
    
  end  
  
  
end
