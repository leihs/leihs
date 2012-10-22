class Category < ModelGroup

  has_many :templates, :through => :models, :uniq => true
  # has_many :all_templates, :through => :all_models, :uniq => true
  def all_templates
    all_models.flat_map(&:templates).uniq
  end

end

