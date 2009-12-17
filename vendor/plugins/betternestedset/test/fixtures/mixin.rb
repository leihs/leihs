class Mixin < ActiveRecord::Base
end

class NestedSet < Mixin
  acts_as_nested_set :scope => "root_id IS NULL"
  def self.table_name() "mixins" end
end

class NestedSetWithStringScope < Mixin
  acts_as_nested_set :scope => 'root_id = #{root_id}'
  def self.table_name() "mixins" end
end

class NS1 < NestedSetWithStringScope
  def self.table_name() "mixins" end
end

class NS2 < NS1
  def self.table_name() "mixins" end
end

class NestedSetWithSymbolScope < Mixin
  acts_as_nested_set :scope => :root
  def self.table_name() "mixins" end
end

class Category < Mixin
  acts_as_nested_set
  def self.table_name() "mixins" end
end
