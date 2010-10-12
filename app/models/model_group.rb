class ModelGroup < ActiveRecord::Base

  has_many :model_links
  has_many :models, :through => :model_links, :uniq => true
  has_and_belongs_to_many :inventory_pools

  validates_presence_of :name

##################################################

  # OPTIMIZE use acts-as-dag plugin instead ?? or dagnabit gem ??
  acts_as_graph :edge_table => "model_groups_parents",
                :child_col => "model_group_id"
  # TODO contribute to acts_as_graph
  def all_children
    children.recursive.to_a
  end
  def all_parents
    parents.recursive.to_a
  end
#  def self_and_all_parent_ids
#    ([id] + all_parents.collect(&:id)).flatten.uniq # OPTIMIZE flatten and unique really needed?
#  end
  def self_and_all_child_ids
    ([id] + all_children.collect(&:id)).flatten.uniq # OPTIMIZE flatten and unique really needed?
  end

  # NOTE is now chainable for named_scopes
  def all_models
    ids = all_children.collect(&:id) << id
    models.by_categories(ids)
  end
  
##################################################
  

  # TODO define roots explicitly?
  named_scope :roots, :joins => "LEFT JOIN model_groups_parents AS mgp ON mgp.model_group_id = model_groups.id",
                      :conditions => ['mgp.model_group_id IS NULL']

  named_scope :leafs, :joins => "LEFT JOIN model_groups_parents AS mgp ON mgp.parent_id = model_groups.id",
                      :conditions => ['mgp.parent_id IS NULL']

################################################

  def to_s
    name
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end

################################################

  def is_root?
    #parents.empty?
    parents.delete_if {|x| x.type != self.type }.empty?
  end
  
  def is_leaf?
    #children.empty?
    children.delete_if {|x| x.type != self.type }.empty?
  end
  


### Edge Label
  def label(parent = nil)
    if parent
      l = ModelGroup.find_by_sql("SELECT label
                                    FROM model_groups_parents
                                    WHERE model_group_id = #{id}
                                      AND parent_id = #{parent.id}")
      return l.first.attributes["label"] if l.first and l.first.attributes["label"] 
    end
    return name
  end

  def set_label(parent, label)
    # TODO prevent sql injections
    ModelGroup.connection.execute("UPDATE model_groups_parents
                                  SET label = '#{label}'
                                  WHERE model_group_id = #{id}
                                    AND parent_id = #{parent.id}")
  end
##################################################

###  TODO alias for Ext.Tree
  def text(parent_id = 0)
    parent = (parent_id == 0 ? nil : ModelGroup.find(parent_id))
    # "#{label(parent)} (#{models.size})" # TODO intersection with current_user.models
    label(parent)
    #"#{label(parent)} (id #{id})" # TODO temp
  end
  
  def leaf
    is_leaf?
  end
###  

  
end
