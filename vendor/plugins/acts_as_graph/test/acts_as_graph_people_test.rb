require 'test/unit'
require File.join(File.dirname(__FILE__), 'ptk_helper')
require File.join(File.dirname(__FILE__), 'test_helper')

class ActsAsGraphTest < Test::Unit::TestCase
  def setup
  end
  
  def test_graph_options
    person_options = { :parent_collection => :people_who_like_me,
                       :parent_col        => "befriender_id",
                       :edge_table        => "people_edges",
                       :child_col         => "friend_id",
                       :allow_cycles      => false,
                       :directed          => true,
                       :child_collection  => :people_i_like  }
    person_options.each do |k, v|
      assert_equal v, Person.acts_as_graph_options[k], "Person.acts_as_graph_options[#{k}]"
    end
  end
  
  def test_graph_with_named_collections
    assert_nothing_raised do
      instantiate_nodes(Person, "tammer", "andy", "todd")
      @tammer.people_i_like << @andy
      @tammer.people_who_like_me << @todd
    end
    assert_equal ["andy"], @tammer.people_i_like.recursive.map(&:name)
    assert_equal ["todd"], @tammer.people_who_like_me.recursive.map(&:name)
  end
  
  def test_friends_recursive_each
    all_friends = %w{brian chad dick ronald}
    instantiate_nodes(Person, "me", *all_friends)
    assert_nothing_raised do
      @me.people_i_like << [@brian, @chad]
      @brian.people_i_like << [@dick, @ronald]
      @chad.people_i_like << [@dick, @ronald]
    end
    temp = []
    @me.people_i_like.recursive.each { |x| temp << x.name }
    assert_equal all_friends.sort, temp.sort
  end
  
end
