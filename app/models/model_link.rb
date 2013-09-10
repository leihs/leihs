class ModelLink < ActiveRecord::Base
  
  belongs_to :model_group, inverse_of: :model_links
  belongs_to :model

  before_validation do
    self.quantity ||= 1
  end

  # prevent duplicated model in Category, but allow for Template
  validates_uniqueness_of :model_id, :scope => :model_group_id,
                                     :message => _("already in Category"),
                                     :if => Proc.new {|ml| ml.model_group.is_a?(Category) }
  validates_presence_of :model_group, :model
  validates_numericality_of :quantity
  
end

