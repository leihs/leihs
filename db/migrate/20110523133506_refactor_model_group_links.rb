class RefactorModelGroupLinks < ActiveRecord::Migration

  class ModelGroupsParent < ActiveRecord::Base
    belongs_to :model_group
    belongs_to :parent, :class_name => 'ModelGroup'  
  end

  def up
    # acts_as_dag
    create_table :model_group_links do |t|
      t.integer :ancestor_id
      t.integer :descendant_id
      t.boolean :direct
      t.integer :count
      t.string  :label
    end
    change_table    :model_group_links do |t|
      t.index       :ancestor_id
      t.index       :descendant_id
      t.index       :direct
    end    

    ModelGroupsParent.all.each do |mgp|
      mgp.model_group.set_parent_with_label(mgp.parent, mgp.label)
    end

    drop_table :model_groups_parents
  end

  def down
  end
end
