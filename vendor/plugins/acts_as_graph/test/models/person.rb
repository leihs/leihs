class Person < ActiveRecord::Base
  acts_as_graph :parent_col        => "befriender_id", 
                :child_col         => "friend_id",
                :parent_collection => :people_who_like_me,
                :child_collection  => :people_i_like
                
  def <=> (other)
    self.name <=> other.name
  end
end
