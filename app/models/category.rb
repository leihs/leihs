class Category < ModelGroup

  has_many :templates, -> { uniq }, :through => :models

  def is_used
    not(self.models.empty? and self.children.empty?)
  end

  def self.filter(params, inventory_pool = nil)
    categories = all
    categories = categories.search(params[:search_term]) if params[:search_term]
    categories = categories.order("name ASC")
    categories
  end

end

