class Category < ModelGroup

  has_many :templates, :through => :models, :uniq => true
  # has_many :all_templates, :through => :all_models, :uniq => true
  def all_templates
    all_models.flat_map(&:templates).uniq
  end

  def is_used
    not(self.models.empty? and self.children.empty?)
  end

  def self.filter(params, inventory_pool = nil)
    categories = scoped
    categories = categories.search(params[:search_term]) if params[:search_term]
    categories = categories.order("name ASC")
    categories
  end

end

