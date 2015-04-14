class Purpose < ActiveRecord::Base
  has_many :contract_lines

  # TODO delete not associated purposes
  # validates has at leas one document_line

  def lines
   contract_lines
  end

  def to_s
    "#{description}"
  end

end
