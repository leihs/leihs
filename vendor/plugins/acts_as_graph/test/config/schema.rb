ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  
  # Set up the Tasks tables (tasks have dependencies)
  ActiveRecord::Base.logger.info "Creating dependencies table"
  create_table "dependencies", :id => false, :force => true do |t|
    t.column "parent_id", :integer, :default => 0, :null => false
    t.column "child_id", :integer, :default => 0, :null => false
  end

  ActiveRecord::Base.logger.info "Creating tasks table"
  create_table "tasks", :force => true do |t|
    t.column "name", :string
  end  

  # Set up the People tables (people have friends)
  ActiveRecord::Base.logger.info "Creating people_edges table"
  create_table "people_edges", :id => false, :force => true do |t|
    t.column "befriender_id", :integer, :default => 0, :null => false
    t.column "friend_id", :integer, :default => 0, :null => false
  end

  ActiveRecord::Base.logger.info "Creating people table"
  create_table "people", :force => true do |t|
    t.column "name", :string
  end  
end