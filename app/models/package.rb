class Package < ModelGroup
  
  has_many :line_groups
  
  # TODO validation: only models with at least one item from the same inventory pool
  
  
  def add_to_document(document, user_id)
    
    quantity = 1 # TODO
    
    lg = LineGroup.create(:package => self)
    
    models.each do |m|
      document.add_line(quantity, m, user_id, nil, nil, lg)
    end
    
  end
  
end
