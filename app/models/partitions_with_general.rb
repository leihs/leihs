# Reading a MySQL View
class PartitionsWithGeneral < ActiveRecord::Base

  belongs_to :model
  belongs_to :inventory_pool
  belongs_to :group

  # overriding (because the nil primary_key)
  def attribute_names_with_no_primary_key
    attribute_names_without_no_primary_key.compact
  end
  alias_method_chain :attribute_names, :no_primary_key

end
