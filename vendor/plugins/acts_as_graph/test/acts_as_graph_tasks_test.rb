require 'test/unit'
require File.join(File.dirname(__FILE__), 'ptk_helper')
require File.join(File.dirname(__FILE__), 'test_helper')

class ActsAsGraphTest < Test::Unit::TestCase
  def setup
  end
  
  def test_graph_options
    task_options = { :parent_collection => :parents,
                     :parent_col        => "parent_id",
                     :edge_table        => "dependencies",
                     :child_col         => "child_id",
                     :allow_cycles      => false,
                     :directed          => true,
                     :child_collection  => :children }
    task_options.each do |k, v|
      assert_equal v, Task.acts_as_graph_options[k], "Task.acts_as_graph_options[#{k}]"
    end
  end

  def test_name_is_saved
    t1 = create_node(Task, :test)
    assert_equal "test", t1.name
  end
  
  def test_can_have_children
    instantiate_nodes(Task, "parent", "child")
    @parent.children << @child
    assert_equal 1, @parent.children.count
    assert_equal "child", @parent.children.first.name
  end
  
  def test_cannot_be_own_child
    instantiate_nodes(Task, "me")
    assert_raises(ArgumentError) do
      @me.children << @me
    end
  end
  
  def test_cannot_be_own_parent
    instantiate_nodes(Task, "me")
    assert_raises(ArgumentError) do
      @me.parents << @me
    end
  end

  def test_cannot_create_cycle_via_push_with_array
    instantiate_nodes(Task, "task1", "task2")
    @task1.children << @task2
    assert_raises(ArgumentError) do
      @task2.children << [@task1]
    end
  end

  def test_cannot_create_cycle_via_push_1
    instantiate_nodes(Task, "task1", "task2")
    @task1.children << @task2
    assert_raises(ArgumentError) do
      @task2.children << @task1
    end
  end
  
  def test_cannot_create_cycle_via_push_2
    instantiate_nodes(Task, "task1", "task2", "task3")
    @task1.children << @task2
    @task2.children << @task3
    assert_raises(ArgumentError) do
      @task3.children << @task1
    end    
  end

  def test_cannot_create_cycle_via_push_3
    instantiate_nodes(Task, "task1", "task2", "task3", "task4")
    @task1.children << @task2
    @task2.children << @task3
    @task3.children << @task4
    assert_raises(ArgumentError) do
      @task4.children << @task1
    end    
  end

  def test_children_recursive_each
    all_children = %w{child1 grandchild1 child2 grandchild2 grandchild3}
    instantiate_nodes(Task, "parent", *all_children)
    assert_nothing_raised do
      @parent.children << [@child1, @child2]
      @child1.children << [@grandchild1, @grandchild3]
      @child2.children << [@grandchild2, @grandchild3]
    end
    temp = []
    @parent.children.recursive.each { |x| temp << x.name }
    assert_equal all_children.sort, temp.sort
  end
  
  def test_parents_recursive_each
    all_parents = %w{mom dad grandma grandpa1 grandpa2 child}
    instantiate_nodes(Task, "me", *all_parents)
    assert_nothing_raised do
      @me.parents  << [@mom, @dad]
      @mom.parents << [@grandma, @grandpa1]
      @dad.parents << [@grandma, @grandpa2]
      @me.children << @child
    end
    temp = []
    @me.parents.recursive.each { |x| temp << x.name }
    assert_equal (all_parents - ["child"]).sort, temp.sort
  end
    
  def test_children_recursive_to_a
    all_children = %w{child1 grandchild1 child2 grandchild2 grandchild3}
    instantiate_nodes(Task, "parent", *all_children)
    assert_nothing_raised do
      @parent.children << [@child1, @child2]
      @child1.children << [@grandchild1, @grandchild3]
      @child2.children << [@grandchild2, @grandchild3]
    end
    assert_equal all_children.sort, @parent.children.recursive.to_a.sort.map(&:name)
  end
  
  def test_children_recursive_enumerable
    family = %w{parent child grandchild}
    assert_nothing_raised do
      instantiate_nodes(Task, *family)
      @parent.children << @child
      @child.children << @grandchild
    end
    assert_equal (family - ["parent"]).sort, @parent.children.recursive.map(&:name).sort
  end
  
  def test_children_recursive_method_missing
    family = %w{parent child grandchild}
    assert_nothing_raised do
      instantiate_nodes(Task, *family)
      @parent.children << @child
      @child.children  << @grandchild
    end
    # Test []
    assert_equal (family - ["parent"]).sort[1], 
                 @parent.children.recursive.sort[1].name
    # Test -
    assert_equal (family - ["parent", "grandchild"]).sort,
                 (@parent.children.recursive - [@grandchild]).sort.map(&:name)
    
  end
  
end
