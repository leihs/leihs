class Category < ModelGroup

  has_many :templates, -> { uniq }, through: :models

  has_many :images, as: :target, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true

  def used?
    not (models.empty? and children.empty?)
  end

  def self.filter(params, _inventory_pool = nil)
    categories = all
    categories = categories.search(params[:search_term]) if params[:search_term]
    categories = categories.order('name ASC')
    categories
  end

  def has_any_models_considering_also_descendants?
    models.present? or
      children.any? { |c| c.has_any_models_considering_also_descendants? }
  end

end
