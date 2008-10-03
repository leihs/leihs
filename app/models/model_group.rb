class ModelGroup < ActiveRecord::Base
  
  acts_as_graph :edge_table => "model_groups_parents",
                :child_col => "model_group_id"
  
  has_many :model_links
  has_many :models, :through => :model_links, :uniq => true

###
  

  # TODO define roots explicitly?
  named_scope :roots, :joins => "LEFT JOIN model_groups_parents AS mgp ON mgp.model_group_id = model_groups.id",
                      :conditions => ['mgp.model_group_id IS NULL']

  named_scope :leafs, :joins => "LEFT JOIN model_groups_parents AS mgp ON mgp.parent_id = model_groups.id",
                      :conditions => ['mgp.parent_id IS NULL']

  
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
      return l.first.attributes["label"]
    else
      return name
    end
  end

  def set_label(parent, label)
    # TODO prevent sql injections
    ModelGroup.connection.execute("UPDATE model_groups_parents
                                  SET label = '#{label}'
                                  WHERE model_group_id = #{id}
                                    AND parent_id = #{parent.id}")
  end
###  

###  TODO alias for Ext.Tree
  def text 
    # "#{label} (#{models.size})" # TODO intersection with current_user.models
    #label
    "#{label} (id #{id})" # TODO temp
  end
  
  def leaf
    is_leaf?
  end
###  

  
end
