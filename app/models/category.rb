class Category < ActiveRecord::Base
  acts_as_graph :edge_table => "categories_parents",
                :child_col => "category_id"
  
####
#  # TODO prevent loops
#  has_and_belongs_to_many :parents,
#                          :class_name => "Category",
#                          :join_table => "categories_parents",
#                          :foreign_key => "category_id",
#                          :association_foreign_key => "parent_id"
#
#  has_and_belongs_to_many :children,
#                          :class_name => "Category",
#                          :join_table => "categories_parents",
#                          :foreign_key => "parent_id",
#                          :association_foreign_key => "category_id"
####

  # TODO indexing models with category_names
  has_and_belongs_to_many :models,
                          :after_add => :model_indexing,
                          :after_remove => :model_indexing
                          
  def model_indexing(model)
    model.save
  end
###
  

  # TODO define roots explicitly?
  named_scope :roots, :joins => "LEFT JOIN categories_parents ON categories_parents.category_id = categories.id",
                      :conditions => ['categories_parents.category_id IS NULL']

  named_scope :leafs, :joins => "LEFT JOIN categories_parents ON categories_parents.parent_id = categories.id",
                      :conditions => ['categories_parents.parent_id IS NULL']

  
  def is_root?
    parents.empty?
  end
  
  def is_leaf?
    children.empty?
  end
  
#  # TODO
#  def ancestors
#  end
#
#  
#  # TODO
#  def is_looping?
##    p = parents
##    begin
##      f = find(:all, :conditions => )
##      a << f
##    do while
#  end
  
  
end
