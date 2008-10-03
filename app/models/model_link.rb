class ModelLink < ActiveRecord::Base
  
  belongs_to :model_group
  belongs_to :model

  # prevent duplicated model in Category, but allow for Template
  validates_uniqueness_of :model_id, :scope => :model_group_id,
                                     :message => _("already in Category"),
                                     :if => Proc.new {|ml| ml.model_group.is_a?(Category) }
  
  after_save :model_indexing                        

                          
  private
                          
  def model_indexing
    model.save if model # TODO *b* remove "if model", nil error adding Templates 
  end
  
end
