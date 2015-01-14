# -*- encoding : utf-8 -*-

class Field < ActiveHash::Base
  include ActiveHash::Associations

  belongs_to :parent, :class_name => "Field", :foreign_key => "visibility_dependency_field_id"
  has_many :children, :class_name => "Field", :foreign_key => "visibility_dependency_field_id"
  
  self.data = [
    {
      id: 1,
      label: "Inventory Code",
      attribute: "inventory_code",
      required: true,
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      group: nil
    },{
      id: 2,
      label: "Model",
      attribute: ["model", "id"],
      value_label: ["model", "product"],
      value_label_ext: ["model", "version"],
      form_name: "model_id",
      required: true,
      type: "autocomplete-search",
      target_type: "item",
      search_path: lambda{|inventory_pool| Rails.application.routes.url_helpers.manage_models_path(inventory_pool, {all: true})},
      search_attr: "search_term",
      value_attr: "id",
      display_attr: "product",
      display_attr_ext: "version",
      group: nil
    },{
      id: 3,
      label: "Software",
      attribute: ["model", "id"],
      value_label: ["model", "product"],
      value_label_ext: ["model", "version"],
      form_name: "model_id",
      required: true,
      type: "autocomplete-search",
      target_type: "license",
      search_path: lambda{|inventory_pool| Rails.application.routes.url_helpers.manage_models_path(inventory_pool, {all: true, type: :software})},
      search_attr: "search_term",
      value_attr: "id",
      display_attr: "product",
      display_attr_ext: "version",
      group: nil
    },{
      id: 4,
      label: "Serial Number",
      attribute: "serial_number",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "General Information"
    },{
      id: 5,
      label: "MAC-Address",
      attribute: ["properties", "mac_address"],
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      target_type: "item",
      group: "General Information"
    },{
      id: 6,
      label: "IMEI-Number",
      attribute: ["properties", "imei_number"],
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      target_type: "item",
      group: "General Information"
    },{
      id: 7,
      label: "Name",
      attribute: "name",
      type: "text",
      target_type: "item",
      group: "General Information",
      forPackage: true
    },{
      id: 8,
      label: "Note",
      attribute: "note",
      type: "textarea",
      group: "General Information",
      forPackage: true
    },{
      id: 9,
      label: "Retirement",
      attribute: "retired",
      type: "select",
      permissions: {role: :lending_manager, owner: true},
      values: [{label: "No", value: false}, {label: "Yes", value: true}],
      default: false,
      group: "Status"
    },{
      id: 10,
      label: "Reason for Retirement",
      attribute: "retired_reason",
      type: "textarea",
      required: true,
      permissions: {role: :lending_manager, owner: true},
      visibility_dependency_field_id: 9,
      visibility_dependency_value: "true",
      group: "Status"
    },{
      id: 11,
      label: "Working order",
      attribute: "is_broken",
      type: "radio",
      target_type: "item",
      values: [{label: "OK", value: false}, {label: "Broken", value: true}],
      default: false,
      group: "Status",
      forPackage: true
    },{
      id: 12,
      label: "Completeness",
      attribute: "is_incomplete",
      type: "radio",
      target_type: "item",
      values: [{label: "OK", value: false}, {label: "Incomplete", value: true}],
      default: false,
      group: "Status",
      forPackage: true
    },{
      id: 13,
      label: "Borrowable",
      attribute: "is_borrowable",
      type: "radio",
      values: [{label: "OK", value: true}, {label: "Unborrowable", value: false}],
      default: false,
      group: "Status",
      forPackage: true
    }, {
      id: 50,
      label: "Status note",
      attribute: "status_note",
      type: "textarea",
      target_type: "item",
      group: "Status",
      forPackage: true
    },{
      id: 14,
      label: "Building",
      attribute: ["location", "building_id"],
      type: "autocomplete",
      target_type: "item",
      values: lambda{([{:value => nil, :label => _("None")}] + Building.all.map {|x| {:value => x.id, :label => x.to_s}}).as_json},
      group: "Location",
      forPackage: true
    },{
      id: 15,
      label: "Room",
      attribute: ["location", "room"],
      type: "text",
      target_type: "item",
      group: "Location",
      forPackage: true
    },{
      id: 16,
      label: "Shelf",
      attribute: ["location", "shelf"],
      type: "text",
      target_type: "item",
      group: "Location",
      forPackage: true
    },{
      id: 17,
      label: "Relevant for inventory",
      attribute: "is_inventory_relevant",
      type: "select",
      target_type: "item",
      permissions: {role: :inventory_manager, owner: true},
      values: [{label: "No", value: false}, {label: "Yes", value: true}],
      default: true,
      group: "Inventory",
      forPackage: true
    },{
      id: 18,
      label: "Owner",
      attribute: ["owner", "id"],
      type: "autocomplete",
      permissions: {role: :inventory_manager, owner: true},
      values: lambda{(InventoryPool.all.map {|x| {:value => x.id, :label => x.name}}).as_json},
      group: "Inventory"
    },{
      id: 19,
      label: "Last Checked",
      attribute: "last_check",
      permissions: {role: :lending_manager, owner: true},
      default: lambda{Date.today.as_json},
      type: "date",
      target_type: "item",
      group: "Inventory",
      forPackage: true
    },{
      id: 20,
      label: "Responsible department",
      attribute: ["inventory_pool", "id"],
      type: "autocomplete",
      values: lambda{(InventoryPool.all.map {|x| {:value => x.id, :label => x.name}}).as_json},
      permissions: {role: :inventory_manager, owner: true},
      group: "Inventory",
      forPackage: true
    },{
      id: 21,
      label: "Responsible person",
      attribute: "responsible",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      target_type: "item",
      group: "Inventory",
      forPackage: true
    },{
      id: 22,
      label: "User/Typical usage",
      attribute: "user_name",
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      target_type: "item",
      group: "Inventory",
      forPackage: true
    },{
      id: 23,
      label: "Reference",
      attribute: ["properties", "reference"],
      permissions: {role: :inventory_manager, owner: true},
      required: true,
      values: [{label: "Running Account", value: "invoice"}, {label: "Investment", value: "investment"}],
      default: "invoice", 
      type: "radio",
      group: "Invoice Information"
    },{
      id: 24,
      label: "Project Number",
      attribute: ["properties", "project_number"],
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      required: true,
      visibility_dependency_field_id: 23,
      visibility_dependency_value: "investment",
      group: "Invoice Information"
    },{
      id: 25,
      label: "Invoice Number",
      attribute: "invoice_number",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      target_type: "item",
      group: "Invoice Information"
    },{
      id: 26,
      label: "Invoice Date",
      attribute: "invoice_date",
      permissions: {role: :lending_manager, owner: true},
      type: "date",
      group: "Invoice Information"
    },{
      id: 27,
      label: "Initial Price",
      attribute: "price",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      currency: true,
      group: "Invoice Information",
      forPackage: true
    },{
      id: 28,
      label: "Supplier",
      attribute: ["supplier", "id"],
      type: "autocomplete",
      extensible: true,
      extended_key: ["supplier", "name"],
      permissions: {role: :lending_manager, owner: true},
      values: lambda{Supplier.order(:name).map {|x| {:value => x.id, :label => x.name}}.as_json},
      group: "Invoice Information"
    },{
      id: 29,
      label: "Warranty expiration",
      attribute: ["properties", "warranty_expiration"],
      permissions: {role: :lending_manager, owner: true},
      type: "date",
      target_type: "item",
      group: "Invoice Information"
    },{
      id: 30,
      label: "Contract expiration",
      attribute: ["properties", "contract_expiration"],
      permissions: {role: :lending_manager, owner: true},
      type: "date",
      target_type: "item",
      group: "Invoice Information"
    },{
      id: 31,
      label: "Umzug",
      attribute: ["properties", "umzug"],
      type: "select",
      target_type: "item",
      values: [{label:"zügeln", value:"zügeln"}, {label:"sofort entsorgen", value:"sofort entsorgen"}, {label:"bei Umzug entsorgen", value:"bei Umzug entsorgen"}, {label:"bei Umzug verkaufen", value:"bei Umzug verkaufen"}],
      default: "zügeln",
      permissions: {role: :inventory_manager, owner: true},
      group: "Umzug"
    },{
      id: 32,
      label: "Zielraum",
      attribute: ["properties", "zielraum"],
      type: "text",
      target_type: "item",
      permissions: {role: :inventory_manager, owner: true},
      group: "Umzug"
    },{
      id: 33,
      label: "Ankunftsdatum",
      attribute: ["properties", "ankunftsdatum"],
      type: "date",
      target_type: "item",
      permissions: {role: :inventory_manager, owner: true},
      group: "Toni Ankunftskontrolle"
    },{
      id: 34,
      label: "Ankunftszustand",
      attribute: ["properties", "ankunftszustand"],
      type: "select",
      target_type: "item",
      values: [{label:"intakt", value:"intakt"}, {label:"transportschaden", value:"transportschaden"}],
      default: "intakt",
      permissions: {role: :inventory_manager, owner: true},
      group: "Toni Ankunftskontrolle"
    },{
      id: 35,
      label: "Ankunftsnotiz",
      attribute: ["properties", "ankunftsnotiz"],
      type: "textarea",
      target_type: "item",
      permissions: {role: :inventory_manager, owner: true},
      group: "Toni Ankunftskontrolle"
    },{
      id: 36,
      label: "Anschaffungskategorie",
      attribute: ["properties", "anschaffungskategorie"],
      value_label: ["properties", "anschaffungskategorie"],
      required: true,
      type: "select",
      target_type: "item",
      values: [{label: "", value: nil}, {label: "Werkstatt-Technik", value: "Werkstatt-Technik"}, {label: "Produktionstechnik", value: "Produktionstechnik"}, {label: "AV-Technik", value: "AV-Technik"}, {label: "Musikinstrumente", value: "Musikinstrumente"}, {label: "Facility Management", value: "Facility Management"}, {label: "IC-Technik/Software", value: "IC-Technik/Software"}],
      default: nil,
      visibility_dependency_field_id: 17,
      visibility_dependency_value: "true",
      permissions: {role: :inventory_manager, owner: true},
      group: "Inventory"
    },{
      id: 37,
      label: "Activation Type",
      attribute: ["properties", "activation_type"],
      type: "select",
      target_type: "license",
      values: [{label: "None", value: "none"},
               {label: "Dongle", value: "dongle"},
               {label: "Serial Number", value: "serial_number"},
               {label: "License Server", value: "license_server"},
               {label: "Challenge Response/System ID", value: "challenge_response"}],
      default: "none",
      permissions: {role: :inventory_manager, owner: true},
      group: "General Information"
    },{
      id: 38,
      label: "Dongle ID",
      attribute: ["properties", "dongle_id"],
      type: "text",
      target_type: "license",
      required: true,
      permissions: {role: :inventory_manager, owner: true},
      visibility_dependency_field_id: 37,
      visibility_dependency_value: "dongle",
      group: "General Information"
    },{
      id: 39,
      label: "License Type",
      attribute: ["properties", "license_type"],
      type: "select",
      target_type: "license",
      values: [{label: "Free", value: "free"},
               {label: "Single Workplace", value: "single_workplace"},
               {label: "Multiple Workplace", value: "multiple_workplace"},
               {label: "Site License", value: "site_license"},
               {label: "Concurrent", value: "concurrent"}],
      default: "free",
      permissions: {role: :inventory_manager, owner: true},
      group: "General Information"
    },{
      id: 40,
      label: "Total quantity",
      attribute: ["properties", "total_quantity"],
      type: "text",
      target_type: "license",
      permissions: {role: :inventory_manager, owner: true},
      visibility_dependency_field_id: 39,
      visibility_dependency_value: ["multiple_workplace", "site_license", "concurrent"],
      group: "General Information"
    },{
      id: 41,
      label: "Quantity allocations",
      attribute: ["properties", "quantity_allocations"],
      type: "composite",
      target_type: "license",
      permissions: {role: :inventory_manager, owner: true},
      visibility_dependency_field_id: 40,
      data_dependency_field_id: 40,
      group: "General Information"
    },{
      id: 42,
      label: "Operating System",
      attribute: ["properties", "operating_system"],
      type: "checkbox",
      target_type: "license",
      values: [{label: "Windows", value: "windows"},
               {label: "Mac OS X", value: "mac_os_x"},
               {label: "Linux", value: "linux"},
               {label: "iOS", value: "ios"}],
      permissions: {role: :inventory_manager, owner: true},
      group: "General Information"
    },{
      id: 43,
      label: "Installation",
      attribute: ["properties", "installation"],
      type: "checkbox",
      target_type: "license",
      values: [{label: "Citrix", value: "citrix"},
               {label: "Local", value: "local"},
               {label: "Web", value: "web"}],
      permissions: {role: :inventory_manager, owner: true},
      group: "General Information"
    },{
      id: 44,
      label: "License expiration",
      attribute: ["properties", "license_expiration"],
      permissions: {role: :inventory_manager, owner: true},
      type: "date",
      target_type: "license",
      group: "General Information"
    },{
      id: 45,
      label: "Maintenance contract",
      attribute: ["properties", "maintenance_contract"],
      type: "select",
      target_type: "license",
      permissions: {role: :inventory_manager, owner: true},
      values: [{label: "No", value: "false"}, {label: "Yes", value: "true"}],
      default: "false",
      group: "Maintenance"
    },{
      id: 46,
      label: "Maintenance expiration",
      attribute: ["properties", "maintenance_expiration"],
      type: "date",
      target_type: "license",
      permissions: {role: :inventory_manager, owner: true},
      visibility_dependency_field_id: 45,
      visibility_dependency_value: "true",
      group: "Maintenance"
    },{
      id: 47,
      label: "Currency",
      attribute: ["properties", "maintenance_currency"],
      type: "select",
      values: [{label: "CHF", value: "CHF"}, {label: "EUR", value: "EUR"}, {label: "USD", value: "USD"}],
      default: "CHF",
      target_type: "license",
      permissions: {role: :inventory_manager, owner: true},
      visibility_dependency_field_id: 46,
      group: "Maintenance"
    },{
      id: 48,
      label: "Price",
      attribute: ["properties", "maintenance_price"],
      type: "text",
      currency: true,
      target_type: "license",
      permissions: {role: :inventory_manager, owner: true},
      visibility_dependency_field_id: 47,
      group: "Maintenance"
    },{
      id: 49,
      label: "Procured by",
      attribute: ["properties", "procured_by"],
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      target_type: "license",
      group: "Invoice Information"
    }
  ]

  def value(item)
    Array(attribute).inject(item) do |r,m|
      if r.is_a?(Hash)
        r[m]
      else
        if m == "id"
          r
        else
          r.try(:send, m)
        end
      end
    end
  end

  def set_default_value(item)
    return unless attributes.has_key?(:default)
    return unless value(item).nil?

    attrs = Array(attribute)
    attrs.inject(item) do |r,m|
      if m == attrs[-1]
        if r.is_a?(Hash)
          r[m] = default
        else
          r.send "#{m}=", default
        end
      else
        if r.is_a?(Hash)
          r[m]
        else
          r.send m
        end
      end
    end
  end

  def values
    if self[:values].is_a? Proc
      self[:values].call
    else
      self[:values]
    end
  end

  def default
    if self[:default].is_a? Proc
      self[:default].call
    else
      self[:default]
    end
  end

  def search_path(inventory_pool)
    if self[:search_path].is_a? Proc
      self[:search_path].call inventory_pool
    else
      self[:search_path]
    end
  end

  def as_json(options = {})
    h = self.attributes.clone
    h[:values] = values
    h[:default] = default
    h[:search_path] = search_path options[:current_inventory_pool]
    h.as_json options
  end

  def get_value_from_params(params)
    if self.attribute.is_a? Array
      begin
        self.attribute.inject(params) {|params,attr| 
          if params.is_a? Hash
            params[attr.to_sym]
          else
            params.send attr
          end
        }
      rescue
        nil
      end
    else
      params[self.attribute]
    end
  end

  def editable(user, inventory_pool, item)
    return true unless self.permissions

    return false if self[:permissions][:role] and not user.has_role? self[:permissions][:role], inventory_pool
    return false if self[:permissions][:owner] and item.owner != inventory_pool

    return true
  end

########

  def accessible_by? user, inventory_pool
    if self[:permissions]
      user.has_role? self[:permissions][:role], inventory_pool
    else
      true
    end
  end

  def has_target_type? type
    self[:target_type].nil? or self[:target_type] == type
  end

end
