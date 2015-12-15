if ActiveRecord::Base.connection.tables.include?('fields')

  predefined_fields = [
      {
          id: :inventory_code,
          label: 'Inventory Code',
          attribute: 'inventory_code',
          required: true,
          permissions: {role: :inventory_manager, owner: true},
          type: 'text',
          group: nil,
          forPackage: true
      }, {
          id: :model_id,
          label: 'Model',
          attribute: ['model', 'id'],
          value_label: ['model', 'product'],
          value_label_ext: ['model', 'version'],
          form_name: 'model_id',
          required: true,
          type: 'autocomplete-search',
          target_type: 'item',
          search_path: :models,
          search_attr: 'search_term',
          value_attr: 'id',
          display_attr: 'product',
          display_attr_ext: 'version',
          group: nil
      }, {
          id: :software_model_id,
          label: 'Software',
          attribute: ['model', 'id'],
          value_label: ['model', 'product'],
          value_label_ext: ['model', 'version'],
          form_name: 'model_id',
          required: true,
          type: 'autocomplete-search',
          target_type: 'license',
          search_path: :software,
          search_attr: 'search_term',
          value_attr: 'id',
          display_attr: 'product',
          display_attr_ext: 'version',
          group: nil
      }, {
          id: :serial_number,
          label: 'Serial Number',
          attribute: 'serial_number',
          permissions: {role: :lending_manager, owner: true},
          type: 'text',
          group: 'General Information'
      }, {
          id: :properties_mac_address,
          label: 'MAC-Address',
          attribute: ['properties', 'mac_address'],
          permissions: {role: :lending_manager, owner: true},
          type: 'text',
          target_type: 'item',
          group: 'General Information'
      }, {
          id: :properties_imei_number,
          label: 'IMEI-Number',
          attribute: ['properties', 'imei_number'],
          permissions: {role: :lending_manager, owner: true},
          type: 'text',
          target_type: 'item',
          group: 'General Information'
      }, {
          id: :name,
          label: 'Name',
          attribute: 'name',
          type: 'text',
          target_type: 'item',
          group: 'General Information',
          forPackage: true
      }, {
          id: :note,
          label: 'Note',
          attribute: 'note',
          type: 'textarea',
          group: 'General Information',
          forPackage: true
      }, {
          id: :retired,
          label: 'Retirement',
          attribute: 'retired',
          type: 'select',
          permissions: {role: :lending_manager, owner: true},
          values: [{label: 'No', value: false}, {label: 'Yes', value: true}],
          default: false,
          group: 'Status'
      }, {
          id: :retired_reason,
          label: 'Reason for Retirement',
          attribute: 'retired_reason',
          type: 'textarea',
          required: true,
          permissions: {role: :lending_manager, owner: true},
          visibility_dependency_field_id: :retired,
          visibility_dependency_value: 'true',
          group: 'Status'
      }, {
          id: :is_broken,
          label: 'Working order',
          attribute: 'is_broken',
          type: 'radio',
          target_type: 'item',
          values: [{label: 'OK', value: false}, {label: 'Broken', value: true}],
          default: false,
          group: 'Status',
          forPackage: true
      }, {
          id: :is_incomplete,
          label: 'Completeness',
          attribute: 'is_incomplete',
          type: 'radio',
          target_type: 'item',
          values: [{label: 'OK', value: false}, {label: 'Incomplete', value: true}],
          default: false,
          group: 'Status',
          forPackage: true
      }, {
          id: :is_borrowable,
          label: 'Borrowable',
          attribute: 'is_borrowable',
          type: 'radio',
          values: [{label: 'OK', value: true}, {label: 'Unborrowable', value: false}],
          default: false,
          group: 'Status',
          forPackage: true
      }, {
          id: :status_note,
          label: 'Status note',
          attribute: 'status_note',
          type: 'textarea',
          target_type: 'item',
          group: 'Status',
          forPackage: true
      }, {
          id: :location_building_id,
          label: 'Building',
          attribute: ['location', 'building_id'],
          type: 'autocomplete',
          target_type: 'item',
          values: :all_buildings,
          group: 'Location',
          forPackage: true
      }, {
          id: :location_room,
          label: 'Room',
          attribute: ['location', 'room'],
          type: 'text',
          target_type: 'item',
          group: 'Location',
          forPackage: true
      }, {
          id: :location_shelf,
          label: 'Shelf',
          attribute: ['location', 'shelf'],
          type: 'text',
          target_type: 'item',
          group: 'Location',
          forPackage: true
      }, {
          id: :is_inventory_relevant,
          label: 'Relevant for inventory',
          attribute: 'is_inventory_relevant',
          type: 'select',
          target_type: 'item',
          permissions: {role: :inventory_manager, owner: true},
          values: [{label: 'No', value: false}, {label: 'Yes', value: true}],
          default: true,
          group: 'Inventory',
          forPackage: true
      }, {
          id: :owner_id,
          label: 'Owner',
          attribute: ['owner', 'id'],
          type: 'autocomplete',
          permissions: {role: :inventory_manager, owner: true},
          values: :all_inventory_pools,
          group: 'Inventory'
      }, {
          id: :last_check,
          label: 'Last Checked',
          attribute: 'last_check',
          permissions: {role: :lending_manager, owner: true},
          default: :today,
          type: 'date',
          target_type: 'item',
          group: 'Inventory',
          forPackage: true
      }, {
          id: :inventory_pool_id,
          label: 'Responsible department',
          attribute: ['inventory_pool', 'id'],
          type: 'autocomplete',
          values: :all_inventory_pools,
          permissions: {role: :inventory_manager, owner: true},
          group: 'Inventory',
          forPackage: true
      }, {
          id: :responsible,
          label: 'Responsible person',
          attribute: 'responsible',
          permissions: {role: :lending_manager, owner: true},
          type: 'text',
          target_type: 'item',
          group: 'Inventory',
          forPackage: true
      }, {
          id: :user_name,
          label: 'User/Typical usage',
          attribute: 'user_name',
          permissions: {role: :inventory_manager, owner: true},
          type: 'text',
          target_type: 'item',
          group: 'Inventory',
          forPackage: true
      }, {
          id: :properties_reference,
          label: 'Reference',
          attribute: ['properties', 'reference'],
          permissions: {role: :inventory_manager, owner: true},
          required: true,
          values: [{label: 'Running Account', value: 'invoice'}, {label: 'Investment', value: 'investment'}],
          default: 'invoice',
          type: 'radio',
          group: 'Invoice Information'
      }, {
          id: :properties_project_number,
          label: 'Project Number',
          attribute: ['properties', 'project_number'],
          permissions: {role: :inventory_manager, owner: true},
          type: 'text',
          required: true,
          visibility_dependency_field_id: :properties_reference,
          visibility_dependency_value: 'investment',
          group: 'Invoice Information'
      }, {
          id: :invoice_number,
          label: 'Invoice Number',
          attribute: 'invoice_number',
          permissions: {role: :lending_manager, owner: true},
          type: 'text',
          target_type: 'item',
          group: 'Invoice Information'
      }, {
          id: :invoice_date,
          label: 'Invoice Date',
          attribute: 'invoice_date',
          permissions: {role: :lending_manager, owner: true},
          type: 'date',
          group: 'Invoice Information'
      }, {
          id: :price,
          label: 'Initial Price',
          attribute: 'price',
          permissions: {role: :lending_manager, owner: true},
          type: 'text',
          currency: true,
          group: 'Invoice Information',
          forPackage: true
      }, {
          id: :supplier_id,
          label: 'Supplier',
          attribute: ['supplier', 'id'],
          type: 'autocomplete',
          extensible: true,
          extended_key: ['supplier', 'name'],
          permissions: {role: :lending_manager, owner: true},
          values: :all_suppliers,
          group: 'Invoice Information'
      }, {
          id: :properties_warranty_expiration,
          label: 'Warranty expiration',
          attribute: ['properties', 'warranty_expiration'],
          permissions: {role: :lending_manager, owner: true},
          type: 'date',
          target_type: 'item',
          group: 'Invoice Information'
      }, {
          id: :properties_contract_expiration,
          label: 'Contract expiration',
          attribute: ['properties', 'contract_expiration'],
          permissions: {role: :lending_manager, owner: true},
          type: 'date',
          target_type: 'item',
          group: 'Invoice Information'
      }, {
          id: :properties_activation_type,
          label: 'Activation Type',
          attribute: ['properties', 'activation_type'],
          type: 'select',
          target_type: 'license',
          values: [{label: 'None', value: 'none'},
                   {label: 'Dongle', value: 'dongle'},
                   {label: 'Serial Number', value: 'serial_number'},
                   {label: 'License Server', value: 'license_server'},
                   {label: 'Challenge Response/System ID', value: 'challenge_response'}],
          default: 'none',
          permissions: {role: :inventory_manager, owner: true},
          group: 'General Information'
      }, {
          id: :properties_dongle_id,
          label: 'Dongle ID',
          attribute: ['properties', 'dongle_id'],
          type: 'text',
          target_type: 'license',
          required: true,
          permissions: {role: :inventory_manager, owner: true},
          visibility_dependency_field_id: :properties_activation_type,
          visibility_dependency_value: 'dongle',
          group: 'General Information'
      }, {
          id: :properties_license_type,
          label: 'License Type',
          attribute: ['properties', 'license_type'],
          type: 'select',
          target_type: 'license',
          values: [{label: 'Free', value: 'free'},
                   {label: 'Single Workplace', value: 'single_workplace'},
                   {label: 'Multiple Workplace', value: 'multiple_workplace'},
                   {label: 'Site License', value: 'site_license'},
                   {label: 'Concurrent', value: 'concurrent'}],
          default: 'free',
          permissions: {role: :inventory_manager, owner: true},
          group: 'General Information'
      }, {
          id: :properties_total_quantity,
          label: 'Total quantity',
          attribute: ['properties', 'total_quantity'],
          type: 'text',
          target_type: 'license',
          permissions: {role: :inventory_manager, owner: true},
          visibility_dependency_field_id: :properties_license_type,
          visibility_dependency_value: ['multiple_workplace', 'site_license', 'concurrent'],
          group: 'General Information'
      }, {
          id: :properties_quantity_allocations,
          label: 'Quantity allocations',
          attribute: ['properties', 'quantity_allocations'],
          type: 'composite',
          target_type: 'license',
          permissions: {role: :inventory_manager, owner: true},
          visibility_dependency_field_id: :properties_total_quantity,
          data_dependency_field_id: :properties_total_quantity,
          group: 'General Information'
      }, {
          id: :properties_operating_system,
          label: 'Operating System',
          attribute: ['properties', 'operating_system'],
          type: 'checkbox',
          target_type: 'license',
          values: [{label: 'Windows', value: 'windows'},
                   {label: 'Mac OS X', value: 'mac_os_x'},
                   {label: 'Linux', value: 'linux'},
                   {label: 'iOS', value: 'ios'}],
          permissions: {role: :inventory_manager, owner: true},
          group: 'General Information'
      }, {
          id: :properties_installation,
          label: 'Installation',
          attribute: ['properties', 'installation'],
          type: 'checkbox',
          target_type: 'license',
          values: [{label: 'Citrix', value: 'citrix'},
                   {label: 'Local', value: 'local'},
                   {label: 'Web', value: 'web'}],
          permissions: {role: :inventory_manager, owner: true},
          group: 'General Information'
      }, {
          id: :properties_license_expiration,
          label: 'License expiration',
          attribute: ['properties', 'license_expiration'],
          permissions: {role: :inventory_manager, owner: true},
          type: 'date',
          target_type: 'license',
          group: 'General Information'
      }, {
          id: :properties_maintenance_contract,
          label: 'Maintenance contract',
          attribute: ['properties', 'maintenance_contract'],
          type: 'select',
          target_type: 'license',
          permissions: {role: :inventory_manager, owner: true},
          values: [{label: 'No', value: 'false'}, {label: 'Yes', value: 'true'}],
          default: 'false',
          group: 'Maintenance'
      }, {
          id: :properties_maintenance_expiration,
          label: 'Maintenance expiration',
          attribute: ['properties', 'maintenance_expiration'],
          type: 'date',
          target_type: 'license',
          permissions: {role: :inventory_manager, owner: true},
          visibility_dependency_field_id: :properties_maintenance_contract,
          visibility_dependency_value: 'true',
          group: 'Maintenance'
      }, {
          id: :properties_maintenance_currency,
          label: 'Currency',
          attribute: ['properties', 'maintenance_currency'],
          type: 'select',
          values: :all_currencies,
          default: 'CHF',
          target_type: 'license',
          permissions: {role: :inventory_manager, owner: true},
          visibility_dependency_field_id: :properties_maintenance_expiration,
          group: 'Maintenance'
      }, {
          id: :properties_maintenance_price,
          label: 'Price',
          attribute: ['properties', 'maintenance_price'],
          type: 'text',
          currency: true,
          target_type: 'license',
          permissions: {role: :inventory_manager, owner: true},
          visibility_dependency_field_id: :properties_maintenance_currency,
          group: 'Maintenance'
      }, {
          id: :properties_procured_by,
          label: 'Procured by',
          attribute: ['properties', 'procured_by'],
          permissions: {role: :inventory_manager, owner: true},
          type: 'text',
          target_type: 'license',
          group: 'Invoice Information'
      }
  ]

  predefined_fields.each_with_index do |predefined_field, i|
      id = predefined_field.delete(:id)
      Field.create_with(id: id, data: predefined_field.as_json, position: i+1).find_or_create_by(id: id)
  end

end

