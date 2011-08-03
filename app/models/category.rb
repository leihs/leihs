# == Schema Information
#
# Table name: model_groups
#
#  id         :integer(4)      not null, primary key
#  type       :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  delta      :boolean(1)      default(TRUE)
#

class Category < ModelGroup

  has_many :templates, :through => :models, :uniq => true
  # has_many :all_templates, :through => :all_models, :uniq => true
  def all_templates
    all_models.collect(&:templates).flatten.uniq
  end

  ######################################################

  define_index do
    indexes :name, :sortable => true

    indexes :id # 0501 forcing indexer even if blank attributes, validates_presence_of :name ???
    
    # TODO 0501 has :parent_id, :child_id
    has inventory_pools(:id), :as => :inventory_pool_id
    
    set_property :delta => true
  end

  # TODO 0501 doesn't work!
  default_sphinx_scope :default_search
  sphinx_scope(:default_search) { {:order => :name, :sort_mode => :asc} }

end

