class Template < ModelGroup

  has_many :line_groups

  acts_as_ferret :fields => [ :name ], :store_class_name => true

  # TODO merge model_links with same models and sum quantities

  
  def add_to_document(document, user_id, quantity = nil)
    lg = LineGroup.create(:model_group => self)
    
    model_links.each do |ml|
      document.add_line(ml.quantity, ml.model, user_id, nil, nil, lg)
    end
  end  
  
  
end
