module ZHdKFields
  def self.up
    zhdk_predefined_fields = [{
                                  id: :properties_umzug,
                                  label: 'Umzug',
                                  attribute: ['properties', 'umzug'],
                                  type: 'select',
                                  target_type: 'item',
                                  values: [{label: 'zügeln', value: 'zügeln'}, {label: 'sofort entsorgen', value: 'sofort entsorgen'}, {label: 'bei Umzug entsorgen', value: 'bei Umzug entsorgen'}, {label: 'bei Umzug verkaufen', value: 'bei Umzug verkaufen'}],
                                  default: 'zügeln',
                                  permissions: {role: :inventory_manager, owner: true},
                                  group: 'Umzug'
                              }, {
                                  id: :properties_zielraum,
                                  label: 'Zielraum',
                                  attribute: ['properties', 'zielraum'],
                                  type: 'text',
                                  target_type: 'item',
                                  permissions: {role: :inventory_manager, owner: true},
                                  group: 'Umzug'
                              }, {
                                  id: :properties_ankunftsdatum,
                                  label: 'Ankunftsdatum',
                                  attribute: ['properties', 'ankunftsdatum'],
                                  type: 'date',
                                  target_type: 'item',
                                  permissions: {role: :inventory_manager, owner: true},
                                  group: 'Toni Ankunftskontrolle'
                              }, {
                                  id: :properties_ankunftszustand,
                                  label: 'Ankunftszustand',
                                  attribute: ['properties', 'ankunftszustand'],
                                  type: 'select',
                                  target_type: 'item',
                                  values: [{label: 'intakt', value: 'intakt'}, {label: 'transportschaden', value: 'transportschaden'}],
                                  default: 'intakt',
                                  permissions: {role: :inventory_manager, owner: true},
                                  group: 'Toni Ankunftskontrolle'
                              }, {
                                  id: :properties_ankunftsnotiz,
                                  label: 'Ankunftsnotiz',
                                  attribute: ['properties', 'ankunftsnotiz'],
                                  type: 'textarea',
                                  target_type: 'item',
                                  permissions: {role: :inventory_manager, owner: true},
                                  group: 'Toni Ankunftskontrolle'
                              }, {
                                  id: :properties_anschaffungskategorie,
                                  label: 'Beschaffungsgruppe',
                                  attribute: ['properties', 'anschaffungskategorie'],
                                  value_label: ['properties', 'anschaffungskategorie'],
                                  required: true,
                                  type: 'select',
                                  target_type: 'item',
                                  values: [{label: '', value: nil}, {label: 'Werkstatt-Technik', value: 'Werkstatt-Technik'}, {label: 'Produktionstechnik', value: 'Produktionstechnik'}, {label: 'AV-Technik', value: 'AV-Technik'}, {label: 'Musikinstrumente', value: 'Musikinstrumente'}, {label: 'Facility Management', value: 'Facility Management'}, {label: 'IC-Technik/Software', value: 'IC-Technik/Software'}, {label: 'Durch Kunde beschafft', value: 'Durch Kunde beschafft'}],
                                  default: nil,
                                  visibility_dependency_field_id: :is_inventory_relevant,
                                  visibility_dependency_value: 'true',
                                  permissions: {role: :inventory_manager, owner: true},
                                  group: 'Inventory'
                              }]

    existing_max_position = Field.pluck(:position).max
    zhdk_predefined_fields.each_with_index do |predefined_field, i|
      id = predefined_field.delete(:id)
      Field.create_with(id: id, data: predefined_field.as_json, position: existing_max_position+i+1).find_or_create_by(id: id)
    end
  end
end
