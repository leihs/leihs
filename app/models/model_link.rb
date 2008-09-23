class ModelLink < ActiveRecord::Base
  
  belongs_to :model_group
  belongs_to :model
                          
  after_save :model_indexing                        

# TODO *a* unique index model_group_id + model_id
                          
  private
                          
  def model_indexing
    model.save if model # TODO *b* remove "if model", nil error adding Templates 
  end
  
end
