class ModelGroup < ActiveRecord::Base
  include Search::Name
  audited

  attr_accessor :current_parent_id

  has_many :model_links, inverse_of: :model_group, dependent: :delete_all
  has_many :models, -> { uniq }, through: :model_links
  has_many :items, -> { uniq }, through: :models

  # has_many :all_model_links,
  #          :class_name => "ModelLink",
  #          :finder_sql => \
  #            proc { ModelLink.where(["model_group_id IN (?)",
  #                   descendant_ids]).to_sql }
  # has_many :all_models,
  #          -> { uniq },
  #          :class_name => "Model",
  #          :through => :all_model_links,
  #          :source => :model

  has_and_belongs_to_many :inventory_pools

  validates_presence_of :name

  accepts_nested_attributes_for :model_links, allow_destroy: true

  ##################################################

  has_dag_links link_class_name: 'ModelGroupLink'

  def self_and_descendant_ids
    # OPTIMIZE: flatten and unique really needed?
    ([id] + descendant_ids).flatten.uniq
  end

  # NOTE it's now chainable for scopes
  def all_models
    Model
      .select('DISTINCT models.*')
      .joins(:model_links)
      .where(model_links: { model_group_id: self_and_descendant_ids })
  end

  def image
    self.images.first || all_models.detect { |m| not m.image.blank? }.try(:image)
  end

  scope :roots, (lambda do
    joins('LEFT JOIN model_group_links AS mgl ' \
          'ON mgl.descendant_id = model_groups.id')
      .where('mgl.descendant_id IS NULL')
  end)

  # scope :accessible_roots, lambda do |user_id|
  # end

  ################################################
  # Edge Label

  def label(parent_id = nil)
    if parent_id
      l = links_as_descendant.find_by(ancestor_id: parent_id)
      return l.try(:label) || name
    end
    name
  end

  def set_parent_with_label(parent, label)
    ModelGroupLink.create_edge(parent, self)
    l = links_as_child.find_by(ancestor_id: parent.id)
    l.update_attributes(label: label) if l
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
