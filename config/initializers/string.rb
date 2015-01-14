class String
  def numeric?
    Float(self) != nil rescue false
  end
end
