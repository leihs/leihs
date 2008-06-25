class Task < ActiveRecord::Base
  acts_as_graph :edge_table => "dependencies"
                
  def <=> (other)
    self.name <=> other.name
  end
end
