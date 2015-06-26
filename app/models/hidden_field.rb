class HiddenField < ActiveRecord::Base

  belongs_to :user, inverse_of: :hidden_fields

end

