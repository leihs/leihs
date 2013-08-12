class Template < ModelGroup
  
  # TODO 12** belongs_to :inventory_pool through
  # TODO 12** validates belongs_to 1 and only 1 inventory pool
  # TODO 12** validates all models are present to current inventory_pool
  # TODO 12** has_many :models through

  ####################################################################################

  def self.filter2(options)
    sql = select("DISTINCT model_groups.*")
    options.each_pair do |k,v|
      case k
        when :inventory_pool_id
          sql = sql.joins(:inventory_pools).where(:inventory_pools_model_groups => {k => v})
      end
    end
    sql
  end

  ####################################################################################
  
  # returns an array of document_lines
  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil, inventory_pool = nil)
    model_links.flat_map do |ml|
      ml.model.add_to_document(document, user_id, ml.quantity, start_date, end_date, inventory_pool)
    end
  end  
  
  def total_quantity
    model_links.sum(:quantity)
  end

  def unaccomplishable_models(user, quantity = nil)
    models.keep_if do |model|
      q = quantity || model_links.detect{|l| l.model_id == model.id}.quantity
      not inventory_pools.any? {|ip| model.total_borrowable_items_for_user(user, ip) >= q}
    end
  end
  
  
end

