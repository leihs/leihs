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

class ModelGroup < ActiveRecord::Base
  
  attr_accessor :current_parent_id

  has_many :model_links
  has_many :models, :through => :model_links, :uniq => true
  has_and_belongs_to_many :inventory_pools

  validates_presence_of :name

##################################################

  has_dag_links :link_class_name => 'ModelGroupLink'

  def self_and_descendant_ids
    ([id] + descendant_ids).flatten.uniq # OPTIMIZE flatten and unique really needed?
  end

  # NOTE is now chainable for scopes
  def all_models
    ids = descendant_ids << id
    models.by_categories(ids)
  end
  
  def image_thumb
    all_models.detect {|m| not m.image_thumb.blank? }.try(:image_thumb)
  end

  scope :roots, joins("LEFT JOIN model_group_links AS mgl ON mgl.descendant_id = model_groups.id").where("mgl.descendant_id IS NULL")

################################################
# Edge Label

  def label(parent_id = nil)
    if parent_id
      l = links_as_descendant.where(:ancestor_id => parent_id).first
      return l.try(:label) || name
    end
    return name
  end

  def set_label(parent, label)
    l = links_as_child.where(:ancestor_id => parent.id).first
    l.update_attributes(:label => label) if l
  end
  
##################################################
# aliases for Ext.Tree # TODO remove ??

  def text(parent_id = 0)
    parent_id = if parent_id == 0 and current_parent_id.to_i > 0
      current_parent_id.to_i
    else
      nil
    end
    label(parent_id)
  end
  
################################################

  def to_s
    name
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end
  
end

