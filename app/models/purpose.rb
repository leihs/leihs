class Purpose < ActiveRecord::Base
  has_many :contract_lines

  # TODO delete not associated purposes
  # validates has at leas one document_line

  def lines
   contract_lines
  end

  def to_s
    description
  end

  def change_description(new_description, scoped_lines = nil)
    if scoped_lines and not lines.all? {|l| scoped_lines.include? l}
      Purpose.create(description: new_description, contract_lines: scoped_lines)
    else
      update_attributes(description: new_description) 
    end
  end

end
