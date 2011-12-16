# == Schema Information
#
# Table name: model_groups
#
#  id         :integer(4)      not null, primary key
#  type       :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  delta      :boolean(1)      default(TRUE)
#

class Category < ModelGroup

  has_many :templates, :through => :models, :uniq => true
  # has_many :all_templates, :through => :all_models, :uniq => true
  def all_templates
    all_models.collect(&:templates).flatten.uniq
  end

  ######################################################

  def self.search2(query)
    return scoped unless query

    w = query.split.map do |x|
      "name LIKE '%#{x}%'"
    end.join(' AND ')
    where(w)
  end

  ######################################################

end

