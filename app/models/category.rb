class Category < ActiveRecord::Base
  acts_as_graph :edge_table => "categories_parents",
                :child_col => "category_id"
  
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
  


### Edge Label
  def label(parent)
    l = Category.find_by_sql("SELECT label
                                  FROM categories_parents
                                  WHERE category_id = #{id}
                                    AND parent_id = #{parent.id}")
    l.first.attributes["label"]
  end

  def set_label(parent, label)
    # TODO prevent sql injections
    Category.connection.execute("UPDATE categories_parents
                                  SET label = '#{label}'
                                  WHERE category_id = #{id}
                                    AND parent_id = #{parent.id}")
  end
###  
  
end
