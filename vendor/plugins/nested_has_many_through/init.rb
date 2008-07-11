require 'nested_has_many_through'
require 'through_association_enhancement'

ActiveRecord::Associations::HasManyThroughAssociation.send :include, NestedHasManyThrough::Association
ActiveRecord::Reflection::AssociationReflection.send :include, NestedHasManyThrough::Reflection
ActiveRecord::Base.send :include, NestedHasManyThrough::AssociationEnhancement
