class HiddenField < ActiveRecord::Base
  audited

  belongs_to :user, inverse_of: :hidden_fields

end
