class ModelGroup < ActiveRecord::Base
  
  attr_accessor :current_parent_id

  has_many :model_links, inverse_of: :model_group, dependent: :delete_all
  has_many :models, -> { uniq }, :through => :model_links
  has_many :items, -> { uniq }, :through => :models
  
  #has_many :all_model_links, :class_name => "ModelLink", :finder_sql => proc { ModelLink.where(["model_group_id IN (?)", descendant_ids]).to_sql }
  #has_many :all_models, -> { uniq }, :class_name => "Model", :through => :all_model_links, :source => :model
  
  has_and_belongs_to_many :inventory_pools

  validates_presence_of :name

  accepts_nested_attributes_for :model_links, allow_destroy: true

##################################################

  has_dag_links :link_class_name => 'ModelGroupLink'

  def self_and_descendant_ids
    ([id] + descendant_ids).flatten.uniq # OPTIMIZE flatten and unique really needed?
  end

  # NOTE it's now chainable for scopes
  def all_models
    Model.select("DISTINCT models.*").joins(:model_links).where(:model_links => {:model_group_id => self_and_descendant_ids})
  end
  
  def image
    self.images.first || all_models.detect {|m| not m.image.blank? }.try(:image)
  end

  scope :with_borrowable_models_for_user, lambda { |user|
    joins(:models).where("models.id IN (#{user.models.borrowable.select("models.id").to_sql})").uniq
  }

  scope :roots, -> {joins("LEFT JOIN model_group_links AS mgl ON mgl.descendant_id = model_groups.id").where("mgl.descendant_id IS NULL")}

  # scope :accessible_roots, lambda do |user_id|     
  # end

######################################################

  scope :search, lambda { |query|
    return all if query.blank?

    q = query.split.map{|s| "%#{s}%"}
    where(arel_table[:name].matches_all(q))
  }

################################################
# Edge Label

  def label(parent_id = nil)
    if parent_id
      l = links_as_descendant.where(:ancestor_id => parent_id).first
      return l.try(:label) || name
    end
    return name
  end

  def set_parent_with_label(parent, label)
    ModelGroupLink.create_edge(parent, self)
    l = links_as_child.where(:ancestor_id => parent.id).first
    l.update_attributes(:label => label) if l
  end
  
################################################

  def to_s
    name
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name.downcase <=> other.name.downcase
  end
  
end

