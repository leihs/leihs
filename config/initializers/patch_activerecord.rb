class ActiveRecord::Base
  def to_i
    self.id
  end

  def self.invalid_records
    all.select {|r| not r.valid? }
  end
  
end
