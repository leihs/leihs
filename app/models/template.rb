class Template < ModelGroup

  # TODO 12** belongs_to :inventory_pool through
  # TODO 12** validates belongs_to 1 and only 1 inventory pool
  # TODO 12** validates all models are present to current inventory_pool
  # TODO 12** has_many :models through

  after_save do
    raise _("Template must have at least one model") if model_links.blank?
  end

  def self.filter(params, inventory_pool)
    templates = inventory_pool.templates
    templates = templates.search(params[:search_term]) unless params[:search_term].blank?
    templates = templates.order("#{params[:sort] || 'name'} #{params[:order] || 'ASC'}")
    templates = templates.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min)
    templates
  end

  ####################################################################################

  # returns an array of contract_lines
  def add_to_contract(contract, user_id, quantity = nil, start_date = nil, end_date = nil)
    model_links.flat_map do |ml|
      ml.model.add_to_contract(contract, user_id, ml.quantity, start_date, end_date)
    end
  end  
  
  def total_quantity
    model_links.sum(:quantity)
  end

  def accomplishable?(user = nil)
    unaccomplishable_models(user).empty?
  end

  def unaccomplishable_models(user = nil, quantity = nil)
    models.keep_if do |model|
      q = quantity || model_links.detect{|l| l.model_id == model.id}.quantity
      not inventory_pools.any? do |ip|
        if user
          model.total_borrowable_items_for_user(user, ip) >= q
        else
          model.borrowable_items.by_responsible_or_owner_as_fallback(ip).count >= q
        end
      end
    end
  end
end

