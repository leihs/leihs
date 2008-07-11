module NestedHasManyThrough::AssociationEnhancement
  def self.included base
    class << base
      alias_method :orig_has_many, :has_many 
      def has_many association_id, options = {}, &extension
        orig_has_many(association_id, options, &extension)
        reflection = reflect_on_association(association_id)
        add_association_callbacks(reflection.name, reflection.options)
      end
    end
  end
end
