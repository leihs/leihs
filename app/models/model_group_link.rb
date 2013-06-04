# -*- encoding : utf-8 -*-
class ModelGroupLink < ActiveRecord::Base
  
  # TODO use dagnabit gem instead ??
  acts_as_dag_links :node_class_name => 'ModelGroup'

end
