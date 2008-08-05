class Package < Template
  
  belongs_to :inventory_pool
  
  validate :available_quantities


  private
  
  # validation: make sure all the model quantities are served by the related inventory pool
  def available_quantities
    errors.add_to_base(_("Not enough available quantities in the inventory pool")) unless model_links.all? { |ml| inventory_pool.items.count(:conditions => {:model_id => ml.model.id}) >= ml.quantity }    
  end

  def maximum_available(date, document_line = nil, current_time = Date.today)
    5
  end

  
end
