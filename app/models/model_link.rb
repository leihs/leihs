class ModelLink < ActiveRecord::Base

  
  belongs_to :model_group
  belongs_to :model
              #, # TODO indexing models with model_group_names
             #:after_add => :model_indexing, 
             #:after_remove => :model_indexing
                          
  #def model_indexing(model)
  #  model.save
  #end
  
end
